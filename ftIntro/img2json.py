import cv2
import numpy as np
import json
import os
import sys

# --- INCREASE RECURSION LIMIT ---
# DFS on images requires a high recursion limit or it will crash
sys.setrecursionlimit(50000)

# --- DEFAULT SETTINGS ---
INPUT_DIR = './imgStuffs/monochrome/'
OUTPUT_DIR = "diagrams"
DEFAULT_RESOLUTION = 5
DEFAULT_RADIUS = 200
# ----------------


def get_user_input():
    if not os.path.exists(INPUT_DIR):
        print(f"Error: Directory '{INPUT_DIR}' does not exist.")
        return None, None, None, None

    files = [f for f in os.listdir(INPUT_DIR) if f.lower().endswith(
        ('.png', '.jpg', '.jpeg', '.bmp'))]
    files.sort()

    if not files:
        print(f"Error: No images found in '{INPUT_DIR}'.")
        return None, None, None, None

    print("\n--- SELECT IMAGE ---")
    for i, f in enumerate(files):
        print(f"[{i}] {f}")

    while True:
        try:
            choice = input(f"\nEnter file index (0-{len(files)-1}): ")
            idx = int(choice)
            if 0 <= idx < len(files):
                selected_file = files[idx]
                break
            else:
                print("Invalid index.")
        except ValueError:
            print("Please enter a number.")

    image_path = os.path.join(INPUT_DIR, selected_file)
    default_name = os.path.splitext(selected_file)[0]
    json_name = input(f"Enter Output Name [default: {default_name}]: ").strip()
    if not json_name:
        json_name = default_name

    res_input = input(f"Enter Resolution [default: {
                      DEFAULT_RESOLUTION}]: ").strip()
    resolution = int(res_input) if res_input.isdigit() else DEFAULT_RESOLUTION

    return image_path, json_name, resolution, DEFAULT_RADIUS


def build_graph(points):
    """
    Converts a list of pixels into a graph (Adjacency Dictionary).
    Key: (x, y)
    Value: List of neighbor (x, y) tuples
    """
    print("Building adjacency graph...")
    point_set = set(map(tuple, points))
    graph = {pt: [] for pt in point_set}

    # Check 8 neighbors for every point
    # (Optimized by only checking points that actually exist)
    for x, y in point_set:
        for dy in [-1, 0, 1]:
            for dx in [-1, 0, 1]:
                if dx == 0 and dy == 0:
                    continue
                nx, ny = x + dx, y + dy
                if (nx, ny) in point_set:
                    graph[(x, y)].append((nx, ny))
    return graph


def dfs_trace(current, graph, visited, path):
    """
    Depth First Search that effectively traces the skeleton.
    If it hits a dead end, the recursion naturally unwinds (backtracks),
    which effectively simulates the pen moving back along the line.
    """
    visited.add(current)
    path.append(current)

    # Sort neighbors to prefer a specific direction (optional, but helps consistency)
    # Here we sort to prioritize continuing in the same general direction if possible,
    # but simple coordinate sorting is stable enough.
    neighbors = sorted(graph[current])

    for neighbor in neighbors:
        if neighbor not in visited:
            dfs_trace(neighbor, graph, visited, path)
            # KEY FIX: If we return from a recursion, it means we hit a dead end
            # and came back. We add 'current' to the path AGAIN.
            # This creates the "retracing" effect so the line is continuous
            # instead of jumping.
            path.append(current)


def main():
    img_path, json_name_out, res, target_rad = get_user_input()
    if img_path is None:
        return

    print(f"\nProcessing: {img_path}")

    # 1. Load & Threshold
    img = cv2.imread(img_path, 0)
    if img is None:
        return

    _, thresh = cv2.threshold(img, 127, 255, cv2.THRESH_BINARY)
    if np.mean(thresh) > 127:
        thresh = cv2.bitwise_not(thresh)

    # 2. Get Pixels
    ys, xs = np.nonzero(thresh)
    points = np.column_stack((xs, ys))

    if len(points) == 0:
        print("Error: Image empty.")
        return

    # 3. Build Graph
    graph = build_graph(points)

    # 4. Trace Paths (DFS)
    visited = set()
    full_ordered_path = []

    # Sort starting points (Top-Left to Bottom-Right) to handle separate words
    all_nodes = sorted(list(graph.keys()), key=lambda k: (k[1], k[0]))

    print("Tracing paths with DFS (Backtracking enabled)...")

    for node in all_nodes:
        if node not in visited:
            # Start a new stroke (e.g., new word)
            # If we already have points, this is a "Pen Up" jump to the next word.
            # Since JSON format is single-line, this jump is unavoidable between separate words,
            # but DFS ensures NO jumps inside the word itself.
            dfs_trace(node, graph, visited, full_ordered_path)

    # 5. Downsample
    # We downsample the FINAL path, which includes the backtracks.
    final_points = full_ordered_path[::res]
    print(f"Path generated with {len(final_points)} points.")

    # 6. Center & Scale
    x_vals = [float(p[0]) for p in final_points]
    y_vals = [float(p[1]) for p in final_points]

    center_x = sum(x_vals) / len(x_vals)
    center_y = sum(y_vals) / len(y_vals)

    x_centered = [x - center_x for x in x_vals]
    y_centered = [y - center_y for y in y_vals]

    max_dist = 0
    for i in range(len(x_centered)):
        dist = np.sqrt(x_centered[i]**2 + y_centered[i]**2)
        if dist > max_dist:
            max_dist = dist
    if max_dist == 0:
        max_dist = 1

    scale_factor = target_rad / max_dist

    formatted_points = []
    for x, y in zip(x_centered, y_centered):
        formatted_points.append({
            "x": round(x * scale_factor, 2),
            "y": round(-(y * scale_factor), 2)
        })

    output_data = {
        "name": json_name_out,
        "points": formatted_points
    }

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    output_filename = os.path.join(OUTPUT_DIR, f"{json_name_out}.json")

    with open(output_filename, 'w') as f:
        json.dump(output_data, f, indent=4)

    print(f"Success! Saved to '{output_filename}'.")


if __name__ == "__main__":
    main()

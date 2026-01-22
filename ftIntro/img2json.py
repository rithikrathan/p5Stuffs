# NOTE: I WILL REWRIT THIS MYSELF, MY EGO WONT LET THIS AI GENERATION STAY
import cv2
import numpy as np
import json
import os
import sys

# --- INCREASE RECURSION LIMIT ---
# Essential for DFS on high-res images to prevent "RecursionError"
sys.setrecursionlimit(100000)

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
    Builds an adjacency list graph where every pixel is connected to its
    8 neighbors. This defines the 'valid' paths the pen can take.
    """
    print("Building connectivity graph...")
    # Using a set for O(1) lookups is much faster than lists
    point_set = set(map(tuple, points))
    graph = {pt: [] for pt in point_set}

    # Iterate over existing points only
    for x, y in point_set:
        # Check all 8 surrounding pixels
        for dy in [-1, 0, 1]:
            for dx in [-1, 0, 1]:
                if dx == 0 and dy == 0:
                    continue
                neighbor = (x + dx, y + dy)
                if neighbor in point_set:
                    graph[(x, y)].append(neighbor)
    return graph


def dfs_trace(current, graph, visited, path):
    """
    Recursive DFS. 
    1. Visits a pixel.
    2. Goes as deep as possible along neighbors.
    3. When it hits a dead end, it returns, adding the node to the path AGAIN.
       This creates the 'backtracking' effect (retracing the line) so the 
       pen doesn't have to jump magically.
    """
    visited.add(current)
    path.append(current)

    # Sorting neighbors ensures we prefer one direction, reducing 'jitter'
    neighbors = sorted(graph[current])

    for neighbor in neighbors:
        if neighbor not in visited:
            dfs_trace(neighbor, graph, visited, path)
            # CRITICAL: Backtrack. If we return from a branch, we must
            # record our position again so the line is continuous.
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

    # Invert if the image is mostly white (we want the black lines)
    if np.mean(thresh) > 127:
        thresh = cv2.bitwise_not(thresh)

    # 2. Get Pixels
    # Note: We do NOT downsample here. We need full resolution to check connectivity.
    ys, xs = np.nonzero(thresh)
    points = np.column_stack((xs, ys))

    if len(points) == 0:
        print("Error: Image empty.")
        return

    print(f"Found {len(points)} pixels. Building graph...")

    # 3. Build Graph (Connectivity)
    graph = build_graph(points)

    # 4. Trace Paths (DFS)
    visited = set()
    full_ordered_path = []

    # Sort nodes to determine starting order for disconnected shapes (like separate letters)
    all_nodes = sorted(list(graph.keys()), key=lambda k: (k[1], k[0]))

    print("Tracing paths...")
    for node in all_nodes:
        if node not in visited:
            # Start a new connected component (e.g., a new letter)
            dfs_trace(node, graph, visited, full_ordered_path)

            # Optional: Add a 'jump' indicator here if your plotter supports it.
            # Currently, the loop just instantly jumps to the next start node.

    # 5. Downsample the PATH
    # We downsample the *ordered list*, preserving the drawing motion but reducing points.
    final_points = full_ordered_path[::res]
    print(f"Path generated with {len(final_points)} points.")

    # 6. Center & Scale
    x_vals = [p[0] for p in final_points]
    y_vals = [p[1] for p in final_points]

    center_x = np.mean(x_vals)
    center_y = np.mean(y_vals)

    x_centered = [x - center_x for x in x_vals]
    y_centered = [y - center_y for y in y_vals]

    # Calculate max distance for scaling
    max_dist = 0
    for x, y in zip(x_centered, y_centered):
        dist = (x**2 + y**2) ** 0.5
        if dist > max_dist:
            max_dist = dist

    if max_dist == 0:
        max_dist = 1
    scale_factor = target_rad / max_dist

    # Format Output
    formatted_points = []
    for x, y in zip(x_centered, y_centered):
        formatted_points.append({
            "x": float(round(x * scale_factor, 2)),
            # Flip Y for standard Cartesian
            "y": float(round(-(y * scale_factor), 2))
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

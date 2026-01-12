import cv2
import numpy as np
import json
import os

# --- DEFAULT SETTINGS ---
INPUT_DIR = './imgStuffs/monochrome/'
OUTPUT_DIR = "diagrams"
DEFAULT_RESOLUTION = 12
DEFAULT_RADIUS = 200
# ----------------


def get_user_input():
    # 1. Check directory
    if not os.path.exists(INPUT_DIR):
        print(f"Error: Directory '{INPUT_DIR}' does not exist.")
        return None, None, None, None

    # 2. List Files
    files = [f for f in os.listdir(INPUT_DIR) if f.lower().endswith(
        ('.png', '.jpg', '.jpeg', '.bmp'))]
    files.sort()

    if not files:
        print(f"Error: No images found in '{INPUT_DIR}'.")
        return None, None, None, None

    print("\n--- SELECT IMAGE ---")
    for i, f in enumerate(files):
        print(f"[{i}] {f}")

    # 3. Get File Index
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

    # 4. Get JSON Name
    # Default to the filename without extension
    default_name = os.path.splitext(selected_file)[0]
    json_name = input(f"Enter Output Name [default: {default_name}]: ").strip()
    if not json_name:
        json_name = default_name

    # 5. Get Resolution
    res_input = input(f"Enter Resolution (higher = less detail) [default: {
                      DEFAULT_RESOLUTION}]: ").strip()
    resolution = int(res_input) if res_input.isdigit() else DEFAULT_RESOLUTION

    return image_path, json_name, resolution, DEFAULT_RADIUS


def main():
    # --- INTERACTIVE PROMPT ---
    img_path, json_name_out, res, target_rad = get_user_input()

    if img_path is None:
        return  # Exit if setup failed

    print(f"\nProcessing: {img_path}")
    print(f"Output: {json_name_out}.json | Res: {res} | Radius: {target_rad}")
    print("-" * 30)

    # 1. Load Image
    img = cv2.imread(img_path, 0)
    if img is None:
        print(f"Error: Could not load image.")
        return

    # 2. Extract Contours
    _, thresh = cv2.threshold(img, 127, 255, cv2.THRESH_BINARY)
    contours, _ = cv2.findContours(
        thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)

    if not contours:
        print("Error: No contours found (Image might be all black or all white).")
        return

    # Flatten contours
    points = []
    for contour in contours:
        for point in contour:
            points.append(point[0])

    total_pixels = len(points)
    print(f"Found {total_pixels} pixels via contours.")

    # 3. Apply Resolution
    ordered_points = points[::res]
    print(f"Downsampled to {len(ordered_points)} points.")

    # 4. Center the shape
    x_vals = [float(p[0]) for p in ordered_points]
    y_vals = [float(p[1]) for p in ordered_points]

    center_x = sum(x_vals) / len(x_vals)
    center_y = sum(y_vals) / len(y_vals)

    x_centered = [x - center_x for x in x_vals]
    y_centered = [y - center_y for y in y_vals]

    # 5. Scale to fit Target Radius
    max_dist = 0
    for i in range(len(x_centered)):
        dist = np.sqrt(x_centered[i]**2 + y_centered[i]**2)
        if dist > max_dist:
            max_dist = dist

    if max_dist == 0:
        max_dist = 1

    scale_factor = target_rad / max_dist
    print(f"Scaling factor applied: {scale_factor:.4f}")

    formatted_points = []
    for x, y in zip(x_centered, y_centered):
        formatted_points.append({
            "x": round(x * scale_factor, 2),
            "y": round(-(y * scale_factor), 2)  # Flip Y
        })

    # 6. Save to File
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

import struct
import random

# Number of vectors to generate
NUM_VECTORS = 1000

# File to write the binary data
filename = "vectors.bin"

def generate_vectors(num_vectors):
    # Open file in binary write mode
    with open(filename, "wb") as f:
        for _ in range(num_vectors):
            # Generate random floats for x, y, z components (in range -100.0 to 100.0)
            x = random.uniform(-100.0, 100.0)
            y = random.uniform(-100.0, 100.0)
            z = random.uniform(-100.0, 100.0)

            # Pack as 3 32-bit floats and write to file
            f.write(struct.pack("ddd", x, y, z))

    print(f"Generated {num_vectors} 3D vectors in {filename}.")

# Generate the binary file
generate_vectors(NUM_VECTORS)


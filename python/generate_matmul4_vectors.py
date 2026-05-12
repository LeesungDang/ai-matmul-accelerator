import numpy as np

NUM_TESTS = 10
DATA_LOW = -8
DATA_HIGH = 8

def main():
    rng = np.random.default_rng(seed=42)

    with open("python/matmul4_vectors.mem", "w") as f:
        for _ in range(NUM_TESTS):
            A = rng.integers(DATA_LOW, DATA_HIGH, size=(4, 4), dtype=np.int8)
            B = rng.integers(DATA_LOW, DATA_HIGH, size=(4, 4), dtype=np.int8)
            C = A.astype(np.int32) @ B.astype(np.int32)

            values = []

            for i in range(4):
                for j in range(4):
                    values.append(int(A[i][j]))

            for i in range(4):
                for j in range(4):
                    values.append(int(B[i][j]))

            for i in range(4):
                for j in range(4):
                    values.append(int(C[i][j]))

            f.write(" ".join(str(v) for v in values) + "\n")

    print(f"Generated {NUM_TESTS} hardware-readable 4x4 matmul test vectors")
    print("Wrote python/matmul4_vectors.mem")

if __name__ == "__main__":
    main()

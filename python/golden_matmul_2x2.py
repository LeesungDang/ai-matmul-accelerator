import numpy as np

def matmul_2x2(a, b):
    return a @ b

if __name__ == "__main__":
    a = np.array([
        [1, 2],
        [3, 4]
    ], dtype=np.int8)

    b = np.array([
        [5, 6],
        [7, 8]
    ], dtype=np.int8)

    c = matmul_2x2(a, b)

    expected = np.array([
        [19, 22],
        [43, 50]
    ])

    print("A =")
    print(a)
    print("B =")
    print(b)
    print("C = A @ B")
    print(c)

    assert np.array_equal(c, expected)
    print("PYTHON 2x2 MATMUL GOLDEN MODEL PASSED")

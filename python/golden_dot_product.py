import numpy as np

def dot_product(a, b):
    return int(np.dot(a, b))

if __name__ == "__main__":
    a = np.array([1, 2, 3, 4], dtype=np.int8)
    b = np.array([5, 6, 7, 8], dtype=np.int8)

    result = dot_product(a, b)

    print("A =", a)
    print("B =", b)
    print("Dot product =", result)

    assert result == 70
    print("PYTHON GOLDEN MODEL PASSED")

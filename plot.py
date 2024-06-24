import matplotlib.pyplot as plt
import matplotlib.patches as patches

byte_per_val = 4
# Initialize min and max memory addresses
# min_point = 23702854340464
min_point = 23702853431056
# Create a figure and axis
fig, ax = plt.subplots(figsize=(16, 8))

x_min = 0
y_min = 0
x_max = 16384
# x_max = 64
y_max = 768
x_width = 1
y_width = 1
ax.set_xlim(x_min, x_max)
ax.set_ylim(y_min, y_max)


class Point:
    def __init__(self, pos, color):
        self.pos = pos
        self.color = color


class Rectangle:
    def __init__(self, xcoord, ycoord, width, height, color):
        self.xcoord = xcoord
        self.ycoord = ycoord
        self.x_width = width
        self.y_width = height
        self.color = color


class Entry:
    # Assumes the fields in this order
    # layer, trans_a, trans_b, trans_c, contig_a, contig_b, contig_c
    # m, n, k, alpha, a, lda, b, ldb, beta, c, ldc
    def __init__(self, fields):
        if (len(fields) != 18):
            raise ValueError("fields has invalid entries")
        self.layer = int(fields[0])
        self.trans_a = fields[1]
        self.trans_b = fields[2]
        self.trans_c = fields[3]
        self.contig_a = int(fields[4])
        self.contig_b = int(fields[5])
        self.contig_c = int(fields[6])
        self.m = int(fields[7])
        self.n = int(fields[8])
        self.k = int(fields[9])
        self.alpha = int(fields[10])
        self.a = int(fields[11], 16) // byte_per_val
        self.lda = int(fields[12])
        self.b = int(fields[13], 16) // byte_per_val
        self.ldb = int(fields[14])
        self.beta = int(fields[15])
        self.c = int(fields[16], 16) // byte_per_val
        self.ldc = int(fields[17])
        minaddr = min(self.a, self.b, self.c)
        if (minaddr < min_point):
            print(minaddr)
            raise ValueError("Min address violated")
        self.a = self.a - min_point
        self.b = self.b - min_point
        self.c = self.c - min_point
        if (self.layer == 1):
            color = 'b'
        elif (self.layer == 2):
            color = 'g'
        elif (self.layer == 0):
            color = 'c'
        else:
            raise ValueError("Unexpected self.layer value")
        self.rec_a = self.__ReturnRec(
            self.a // byte_per_val, self.lda,
            (self.k if self.trans_a == "TransposeA" else self.m),
            (self.m if self.trans_a == "TransposeA" else self.k), color)
        # self.points_a = self.__ReturnPoints(
        #     self.a // 4, self.lda,
        #     (self.k if self.trans_a == "TransposeA" else self.m),
        #     (self.m if self.trans_a == "TransposeA" else self.k), color)
        if (self.layer == 1):
            color = 'r'
        elif (self.layer == 2):
            color = 'm'
        elif (self.layer == 0):
            color = 'y'
        else:
            raise ValueError("Unexpected layer value")
        self.rec_b = self.__ReturnRec(
            self.b // byte_per_val, self.ldb,
            (self.n if self.trans_b == "TransposeB" else self.k),
            (self.k if self.trans_b == "TransposeB" else self.n), color)
        # self.points_b = self.__ReturnPoints(
        #     self.b // 4, self.ldb,
        #     (self.n if self.trans_b == "TransposeB" else self.k),
        #     (self.k if self.trans_b == "TransposeB" else self.n), color)
        color = 'k'
        self.rec_c = self.__ReturnRec(
            self.c // byte_per_val, self.ldc, self.m, self.n, color)
        # self.points_c = self.__ReturnPoints(
        #     self.c // 4, self.ldc, self.m, self.n, color)
        self.rec = self.rec_a + self.rec_b + self.rec_c

    def __ReturnPoints(self, begin_point, ld, param1, param2, color):
        retlist = []
        pos = begin_point
        for j in range(0, param2):
            for i in range(0, param1):
                retlist.append(Point(pos, color))
                pos += 1
            pos += ld
        return retlist

    def __ReturnRec(self, begin_point, ld, param1, param2, color):
        retlist = []
        pos = begin_point
        for j in range(0, param2):
            xcoord = pos // y_max
            ycoord = pos % y_max
            width = x_width
            size = y_width * param1
            while size + ycoord > y_max:
                height = y_max - ycoord
                retlist.append(
                    Rectangle(xcoord, ycoord,
                              width, height, color))
                xcoord += x_width
                ycoord = 0
                size = size - height
            retlist.append(Rectangle(xcoord, ycoord, width, size, color))
            pos += ld
        return retlist


# Read file
with open('trace.txt', 'r') as f:
    trace = f.readlines()


for entry in trace:
    fields = entry.strip().split()
    curr_entry = Entry(fields)
    for rec in curr_entry.rec:
        sq = patches.Rectangle((rec.xcoord, rec.ycoord), rec.x_width,
                               rec.y_width, fill=True, color=rec.color)
        ax.add_patch(sq)
    plt.pause(0.1)

# # Get an array of memory addresses
# addresses = np.random.randint(0, 1000, size=100)


# ax.axis([0, y_max+1, 0, x_max+1])
plt.axis('off')
# plt.grid(b=True, which='major', color='b', linestyle='-')
plt.show()

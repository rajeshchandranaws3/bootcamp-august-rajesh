# list comprehension


# normal way

# l = []

# for i in range(1, 25, 5):
#     new_i = i*2
#     l.append(new_i)

# print(l)

# better way 

print([ i*2 for i in range(1, 25, 5)])
db_link = "postgresql://postgres:admin1234@dev-app-db.cvik8accw2tk.ap-south-1.rds.amazonaws.com:5432/mydb"


# s='asdf:asr6:8345t43:111@234'
# print(s.split(":")[-1].split("@")[0])
# print(s.split("@")[0].split(":")[-1])

# print(db_link.split("//")[-1].split(":")[0])
# print(db_link.split("//")[-1].split(":")[1].split("@")[0])
# print(db_link.split("//")[-1].split(":")[1].split("@")[-1])
# print(db_link.split("//")[-1].split(":")[1].split("@")[-1].split(".")[0])
# print(db_link.split(":")[-1].split("/")[-1])


old_host = db_link.split("//")[-1].split(":")[1].split("@")[-1]
print(old_host)

# dev-app-db  .    cvik8accw2tk.ap-south-1.rds.amazonaws.com
new_host_left_part = old_host.split(".")[0] + "-new"
# new_host_right_part = old_host.split(".")[1:]

# split -> take string and convert to a list from seperator
# join -> take list and convert to string with seperator
new_host_right_part = ".".join(old_host.split(".")[1:])
new_host= new_host_left_part + "."+ new_host_right_part

# print(new_host_left_part + "."+ new_host_right_part)
print(old_host, new_host)
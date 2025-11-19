import argparse
import sys

# There are 2 types of arguments
# 1. Positional Arguments (Mandatory)   
# 2. Keyword/Optional Arguments  (Not Mandatory)

#print a help function if no arguments are provided
def help():
    print("""Multiline Help:
          line 1 - Argument 
          line 2 - Parser 
          line 3 - Help
          """)
    print("Usage: python arg-parsing.py <name> <age> [-c CITY]")
    print("Positional Arguments:")
    print("  name        Your name (string)")
    print("  age         Your age (integer)")
    print("Optional Arguments:")
    print("  -c, --city  Your city (string, default: 'Unknown')")


def main():
    parser = argparse.ArgumentParser(description="A simple argument parser example.")
    parser.add_argument("name", type=str, help="Your name")
    parser.add_argument("age", type=int, help="Your age", default=0)
    parser.add_argument("-c", "--city", type=str, help="Your city", default="Unknown") # Keyword arguments are by default "required=False"

    print("list of arguments: {}".format(sys.argv))
    print("type of arguments: {}".format(type(sys.argv)))
    print("number of arguments: {}".format(len(sys.argv)))
    print("-----")


    #call help function if no arguments are provided
    if len(sys.argv)==1:
        help()  
        sys.exit(1)

    args = parser.parse_args()

    output = f"Hello {args.name}. You are {args.age} years old."
 
    if args.city:
        output += f" You live in {args.city}."
    print(output)


if __name__ == "__main__":
    main()



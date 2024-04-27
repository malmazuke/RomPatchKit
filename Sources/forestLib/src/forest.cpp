#include "tree.h"
#include <iostream>
#include <string>

std::string getForest() {
    std::string tree = getTree();
    return "This is a forest with a tree: " + tree;
}

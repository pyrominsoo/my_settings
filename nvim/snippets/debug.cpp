#ifdef NDEBUG
#define delog(x)
#define debug(...)
#else
#include <iostream>
#define delog(x) [](std::string str){ std::cout << str;}(x)
#define debug(...) logger(#__VA_ARGS__, __VA_ARGS__)
template <typename... Args>
void logger(std::string vars, Args&&... values) {
    std::cout << vars << " = ";
    std::string delim = "";
    (..., (std::cout << delim << values, delim = ", "));
    std::cout << std::endl;
}
#endif

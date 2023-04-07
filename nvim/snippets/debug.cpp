#ifdef NDEBUG
#define debug(...)
#else
#include <iostream>
#define debug(x, ...) logger(x, #__VA_ARGS__, __VA_ARGS__)
template <typename... Args>
void logger(std::string str, std::string vars, Args&&... values) {
    std::cout << str << ": ";
    std::cout << vars << " = ";
    std::string delim = "";
    (..., (std::cout << delim << values, delim = ", "));
    std::cout << std::endl;
}
#endif

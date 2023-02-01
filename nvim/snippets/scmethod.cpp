DEFINES
sc_event FUNCTION_E;

CONSTRUCTOR
    SC_METHOD(FUNCTION);
    sensitive << FUNCTION_E;
    dont_initialize();

FUNCTION
void FUNCTION() {
    // something
}

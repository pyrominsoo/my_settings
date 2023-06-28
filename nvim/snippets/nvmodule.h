/*
 * ----------------------------------------------------------------------
 *        (c) copyright 2023. All rights reserved. Western Digital
 *         Company confidential and proprietary information.
 *  This information may not be disclosed to unauthorized individual.
 * ----------------------------------------------------------------------
 * @author: Min Soo Kim     min.soo.kim@wdc.com
 * @date:   06/28/2023
 */

#ifndef NAVIS_MODULE_SNIPPET
#define NAVIS_MODULE_SNIPPET

#include <systemc>

#include "infra/NV.h"

using namespace sc_core;

class ClassName : public NV_MODULE {
   public:
    /* SC_CTOR(ClassName) {} */
    SC_HAS_PROCESS(ClassName);

    ClassName(sc_module_name name)
        : NV_MODULE(name) {
    }

   private:
};

#endif  // NAVIS_MODULE_SNIPPET

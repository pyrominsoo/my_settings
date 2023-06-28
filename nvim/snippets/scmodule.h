/*
 * ----------------------------------------------------------------------
 *        (c) copyright 2023. All rights reserved. Western Digital
 *         Company confidential and proprietary information.
 *  This information may not be disclosed to unauthorized individual.
 * ----------------------------------------------------------------------
 * @author: Min Soo Kim     min.soo.kim@wdc.com
 * @date:   05/12/2023
 */
#ifndef SYSTEMC_MODULE_SNIPPET_H
#define SYSTEMC_MODULE_SNIPPET_H

#include <tlm_utils/peq_with_cb_and_phase.h>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

#include <systemc>

using namespace sc_core;

class ClassName : public sc_module {
   public:
    /* SC_CTOR(ClassName) {} */
    SC_HAS_PROCESS(ClassName);

    ClassName(sc_module_name name)
        : sc_module(name) {
    }

   private:
};

#endif  // SYSTEMC_MODULE_SNIPPET_H

/*
 * ----------------------------------------------------------------------
 *        (c) copyright 2023. All rights reserved. Western Digital
 *         Company confidential and proprietary information.
 *  This information may not be disclosed to unauthorized individual.
 * ----------------------------------------------------------------------
 * @author: Min Soo Kim     min.soo.kim@wdc.com
 * @date:   05/12/2023
 */

#ifndef NAVIS_MODULE_SNIPPET
#define NAVIS_MODULE_SNIPPET

#include <queue>
#include <systemc>

#include "infra/NV.h"

using namespace sc_core;

class ClassName : public sc_module {
   public:
    /* SC_CTOR(ClassName) {} */
    SC_HAS_PROCESS(ClassName);

    NV_InitiatorSocket INITSOCKET;
    NV_InitiatorSocket::ReqContext REQCTX;

    NV_TargetSocket TARGSOCKET;
    std::queue<NV_Transaction *> TRANSQ;

    sc_event SENDFUNC_EVENT;
    sc_event SENDRESP_EVENT;

    ClassName(sc_module_name name)
        : sc_module(name),
          INITSOCKET("NAME", ID, this),
          TARGSOCKET("SKNAME", SKID, this, NV_TCF(&ClassName::TARG_REQ_HANDLER),
                     MAXCMDS) {
        SC_METHOD(SENDFUNC);
        sensitive << SENDFUNC_EVENT;

        SC_METHOD(SENDRESP);
        sensitive << SENDRESP_EVENT;
    }

    void SENDFUNC() {
        REQCTX.delay = SC_ZERO_TIME;
        REQCTX.trans =
            NV::get_trans(tlm::TLM_WRITE_COMMAND, TRANSADDR, TRANSLEN,
                          reinterpret_cast<unsigned char *>(DATA_PTR));
        REQCTX.cmpCb = NV_ICBF(&ClassName::INIT_RESP_HANDLER);
        REQCTX.latCb = NV_ILF(&ClassName::INIT_LATENCY);
        REQCTX.taCb = NV_ITACBF(&ClassName::INIT_TRANS_ACCEPTED);
        INITSOCKET.send_req(&REQCTX);
    }

    void INIT_RESP_HANDLER(const unsigned int id,
                           NV_InitiatorSocket::ReqContext *req) {
        NV::free_trans(REQCTX.trans);
    }

    void INIT_LATENCY(const unsigned int id,
                      NV_InitiatorSocket::ReqContext *req,
                      sc_core::sc_time delay) {
        // LG3("MSG")
    }

    sc_core::sc_time INIT_TRANS_ACCEPTED(const unsigned int id,
                                         NV_InitiatorSocket::ReqContext *req,
                                         sc_core::sc_time delay) {
        // LG3("MSG")
        initiatorReadyEvent.notify(sc_time(120, SC_NS));
        return SC_MAX_TIME;
    }

    NV_TransactionStatus TARG_REQ_HANDLER(const unsigned int id,
                                          NV_Transaction &trans) {
        LG5("MSG");
        TRANSQ.push(&trans);
        SENDRESP_EVENT.notify(SOMEDELAY);
        return NV_TRANS_NOT_DONE;
    }

    void SENDRESP() {
        NV_Transaction *currTrans = TRANSQ.front();
        TRANSQ.pop();
        DATATYPE *data_ptr =
            reinterpret_cast<DATATYPE *>(currTrans->get_data_ptr());
        (*data_ptr) = SOMEDATA;
        TARGSOCKET.send_resp(*currTrans);
        LG5("MSG");
    }

   private:
};

// TODO Do this one level up
INITSOCKET.set_clock_period(SKCLOCKPERIOD);
INITSOCKET.set_bus_width(SKBUSWIDTH);
INITSOCKET.bind(TARGETSK);
TARGSOCKET.set_clock_period(clockPeriod);
TARGSOCKET.set_bus_width(4);
INITSOCKET.bind(TARGETSK);

#endif  // NAVIS_MODULE_SNIPPET

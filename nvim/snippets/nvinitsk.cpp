#include "infra/NV.h"

DEFINE
NV_InitiatorSocket INITSOCKET;
NV_InitiatorSocket::ReqContext REQCTX;

CONSTRUCT
INITSOCKET("NAME", ID, this);
SC_METHOD(SENDFUNC);
sensitive << SENDFUNC_EVENT;

SEND
void SENDFUNC() {
    REQCTX.delay = SC_ZERO_TIME;
    REQCTX.trans =
        NV::get_trans(TLM_WRITE_COMMAND, TRANSADDR, TRANSLEN,
                      reinterpret_cast<unsigned char *>(DATA_PTR));
    REQCTX.cmpCb = NV_ICBF(&ClassName::INIT_RESP_HANDLER);
    REQCTX.latCb = NV_ILF(&ClassName::INIT_LATENCY);
    REQCTX.taCb = NV_ITACBF(&ClassName::INIT_TRANS_ACCEPTED);
    INITSOCKET.send_req(&REQCTX);
}

CALLBACK
void INIT_RESP_HANDLER(const unsigned int id,
                                NV_InitiatorSocket::ReqContext *req) {
  NV::free_trans(REQCTX.trans);
}

void INIT_TRANS_ACCEPTED(const unsigned int id,
                              NV_InitiatorSocket::ReqContext *req,
                              sc_core::sc_time delay) {
  // LG3("MSG")
}

sc_core::sc_time INIT_LATENCY(const unsigned int id,
                                   NV_InitiatorSocket::ReqContext *req,
                                   sc_core::sc_time delay) {
  // LG3("MSG")
  initiatorReadyEvent.notify(sc_time(120, SC_NS));
  return SC_MAX_TIME;
}

CONNECTION
INITSOCKET.set_clock_period(SKCLOCKPERIOD);
INITSOCKET.set_bus_width(SKBUSWIDTH);
INITSOCKET.bind(TARGETSK);

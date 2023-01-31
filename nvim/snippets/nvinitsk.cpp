#include "infra/NV.h"

DEFINE
NV_InitiatorSocket INITSOCKET;
NV_InitiatorSocket::ReqContext REQCTX;

CONSTRUCT
INITSOCKET("NAME", ID, this);

SEND
REQCTX.delay = SC_ZERO_TIME;
REQCTX.trans = NV::get_trans(TLM_WRITE_COMMAND, TRANSADDR, TRANSLEN,
                             reinterpret_cast<unsigned char *>(DATA_PTR));
REQCTX.cmpCb = NV_ICBF(&ClassName::INIT_resp_handler);
REQCTX.latCb = NV_ILF(&ClassName::INIT_latency);
REQCTX.taCb = NV_ITACBF(&ClassName::INIT_trans_accepted);
INITSOCKET.send_req(&REQCTX);

CALLBACK
void initiator_response_handler(const unsigned int id,
                                NV_InitiatorSocket::ReqContext *req) {
  NV::free_trans(REQCTX.trans);
}

void initiator_trans_accepted(const unsigned int id,
                              NV_InitiatorSocket::ReqContext *req,
                              sc_core::sc_time delay) {
  // LG3("MSG")
}

sc_core::sc_time initiator_latency(const unsigned int id,
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

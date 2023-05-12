#include "infra/NV.h"

DEFINE
NV_TargetSocket TARGSOCKET;
std::queue<NV_Transaction*> TRANSQ;

CONSTRUCT
TARGSOCKET("SKNAME", SKID, this, NV_TCF(&ClassName::TARG_REQ_HANDLER), MAXCMDS);
SC_METHOD(SENDRESP);
sensitive << SENDRESP_EVENT;

CALLBACK
NV_TransactionStatus TARG_REQ_HANDLER(const unsigned int id,
                                           NV_Transaction& trans) {
    LG5("MSG");
    TRANSQ.push(&trans);
    SENDRESP_EVENT.notify(SOMEDELAY);
    return NV_TRANS_NOT_DONE;
}

void SENDRESP() {
    NV_Transaction* currTrans = TRANSQ.front();
    TRANSQ.pop();
    DATATYPE* data_ptr =
        reinterpret_cast<DATATYPE*>(currTrans->get_data_ptr());
    (*data_ptr) = SOMEDATA;
    TARGSOCKET.send_resp(*currTrans);
    LG5("MSG");
}

CONNECTION
TARGSOCKET.set_clock_period(clockPeriod);
TARGSOCKET.set_bus_width(4);
INITSOCKET.bind(TARGETSK);

/*
 *  Copyright (c) 2021 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#ifndef MEDIA_SCTP_SCTP_TRANSPORT_FACTORY_H_
#define MEDIA_SCTP_SCTP_TRANSPORT_FACTORY_H_

#include <memory>

#include "api/transport/sctp_transport_factory_interface.h"
#include "api/webrtc_key_value_config.h"
#include "media/sctp/sctp_transport_internal.h"
#include "rtc_base/experiments/field_trial_parser.h"
#include "rtc_base/thread.h"

namespace cricket {

class SctpTransportFactory : public webrtc::SctpTransportFactoryInterface {
 public:
  explicit SctpTransportFactory(
      rtc::Thread* network_thread,
      const webrtc::WebRtcKeyValueConfig& field_trials);

  std::unique_ptr<SctpTransportInternal> CreateSctpTransport(
      rtc::PacketTransportInternal* transport) override;

 private:
  rtc::Thread* network_thread_;
  webrtc::FieldTrialFlag use_usrsctp_;
};

}  // namespace cricket

#endif  // MEDIA_SCTP_SCTP_TRANSPORT_FACTORY_H__
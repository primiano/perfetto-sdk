/*
 * Copyright (C) 2019 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "perfetto.h"

// Deliberately not pulling any non-public perfetto header to spot accidental
// header public -> non-public dependency while building this file.

class MyDataSource : public perfetto::DataSource<MyDataSource> {
 public:
  void OnSetup(const SetupArgs& args) override {
    // This can be used to access the domain-specific DataSourceConfig, via
    // args.config->xxx_config_raw().
    PERFETTO_ILOG("OnSetup called, name: %s", args.config->name().c_str());
  }

  void OnStart(const StartArgs&) override { PERFETTO_ILOG("OnStart called"); }

  void OnStop(const StopArgs&) override { PERFETTO_ILOG("OnStop called"); }
};

PERFETTO_DEFINE_DATA_SOURCE_STATIC_MEMBERS(MyDataSource);

int main() {
  perfetto::TracingInitArgs args;
  args.backends = perfetto::kSystemBackend;
  perfetto::Tracing::Initialize(args);

  // DataSourceDescriptor can be used to advertise domain-specific features.
  perfetto::DataSourceDescriptor dsd;
  dsd.set_name("com.example.mytrace");
  MyDataSource::Register(dsd);

  for (;;) {
    MyDataSource::Trace([](MyDataSource::TraceContext ctx) {
      PERFETTO_LOG("Tracing lambda called");
      auto packet = ctx.NewTracePacket();
      packet->set_timestamp(42);
      packet->set_for_testing()->set_str("event 1");
    });
    sleep(1);
  }
}

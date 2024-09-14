


import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:omnigram/providers/api.provider.dart';
import 'package:openapi/openapi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server_info.provider.g.dart';

@riverpod
class ServerInfo extends _$ServerInfo {
  @override
  Future<SysInfoDto> build() async {
     final service = ref.read(apiServiceProvider);
   try {
      final infoResp = await service.sysInfoGet();

      if (infoResp.statusCode == 200) {

        return infoResp.data!;
    
      }

      
    } catch (e) {
      debugPrint(e.toString());
    }

    return  SysInfoDto();
  }

  Future<bool> updateInfo() async {
    final service = ref.read(apiServiceProvider);

    try {
      final infoResp = await service.sysInfoGet();

      if (infoResp.statusCode == 200) {
        final updated = infoResp.data!;
   
        state = AsyncValue.data(updated);
      }

      return true;
    } catch (e) {
      return false;
    }

    
  }

  
}

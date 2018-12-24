import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:invoiceninja_flutter/data/models/serializers.dart';
import 'package:built_collection/built_collection.dart';

import 'package:invoiceninja_flutter/redux/auth/auth_state.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/data/web_client.dart';

class TasksRepository {
  const TasksRepository({
    this.webClient = const WebClient(),
  });

  final WebClient webClient;

  Future<BuiltList<TaskEntity>> loadList(
      CompanyEntity company, AuthState auth) async {
    final dynamic response =
        await webClient.get(auth.url + '/tasks?per_page=500', company.token);

    final TaskListResponse taskResponse =
        serializers.deserializeWith(TaskListResponse.serializer, response);

    return taskResponse.data;
  }

  Future<TaskEntity> saveData(
      CompanyEntity company, AuthState auth, TaskEntity task,
      [EntityAction action]) async {
    final data = serializers.serializeWith(TaskEntity.serializer, task);
    dynamic response;

    if (task.isNew) {
      response = await webClient.post(
          auth.url + '/tasks', company.token, json.encode(data));
    } else {
      var url = auth.url + '/tasks/' + task.id.toString();
      if (action != null) {
        url += '?action=' + action.toString();
      }
      response = await webClient.put(url, company.token, json.encode(data));
    }

    final TaskItemResponse taskResponse =
        serializers.deserializeWith(TaskItemResponse.serializer, response);

    return taskResponse.data;
  }
}

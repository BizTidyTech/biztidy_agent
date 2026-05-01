import 'dart:convert';
import 'package:biztidy_agent_app/ui/features_agent/agent_auth/agent_auth_model/agent_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _agentKey = 'saved_agent_data';

Future<void> saveAgentDetailsLocally(AgentModel agent) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(_agentKey, jsonEncode(agent.toJson()));
}

Future<AgentModel?> getLocallySavedAgentDetails() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString(_agentKey);
  if (jsonString == null) return null;
  return AgentModel.fromJson(jsonDecode(jsonString));
}

Future<void> clearAgentDetailsLocally() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(_agentKey);
}

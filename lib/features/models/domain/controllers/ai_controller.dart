import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../models/ai_model.dart';
import '../repositories/i_ai_repository.dart';
import '../../../../core/error/failures.dart';

@lazySingleton

class AiController {
  final IAiRepository _repository;

  AiController(this._repository);

  Future<Either<Failure, List<AIConversationLogModel>>> getConversationLogs(String childId) => _repository.getConversationLogs(childId);
  Future<Either<Failure, List<AIMessageModel>>> getMessages(String conversationId) => _repository.getMessages(conversationId);
  Future<Either<Failure, AIMessageModel>> sendMessage(String conversationId, String content) => _repository.sendMessage(conversationId, content);
  Future<Either<Failure, List<TaskSuggestionModel>>> getTaskSuggestions(String childId) => _repository.getTaskSuggestions(childId);
}

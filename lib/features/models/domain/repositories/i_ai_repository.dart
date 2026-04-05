import 'package:dartz/dartz.dart';
import '../models/ai_model.dart';
import '../../../../core/error/failures.dart';

abstract class IAiRepository {
  Future<Either<Failure, List<AIConversationLogModel>>> getConversationLogs(String childId);
  Future<Either<Failure, List<AIMessageModel>>> getMessages(String conversationId);
  Future<Either<Failure, AIMessageModel>> sendMessage(String conversationId, String content);
  Future<Either<Failure, List<TaskSuggestionModel>>> getTaskSuggestions(String childId);
}

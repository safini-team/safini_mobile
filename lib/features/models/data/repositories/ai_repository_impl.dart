import 'package:dartz/dartz.dart';
import '../../domain/models/ai_model.dart';
import '../../domain/repositories/i_ai_repository.dart';
import '../../../../core/error/failures.dart';

class AiRepositoryImpl implements IAiRepository {
  @override
  Future<Either<Failure, List<AIConversationLogModel>>> getConversationLogs(
    String childId,
  ) async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, List<AIMessageModel>>> getMessages(
    String conversationId,
  ) async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, AIMessageModel>> sendMessage(
    String conversationId,
    String content,
  ) async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, List<TaskSuggestionModel>>> getTaskSuggestions(
    String childId,
  ) async {
    return const Left(ServerFailure('Not implemented'));
  }
}

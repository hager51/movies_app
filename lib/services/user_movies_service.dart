import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie_model.dart';

class UserMoviesService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get uid => auth.currentUser?.uid ?? 'none';

  CollectionReference<Map<String, dynamic>> get watchlistRef =>
      firestore.collection('users').doc(uid).collection('watchlist');

  CollectionReference<Map<String, dynamic>> get historyRef =>
      firestore.collection('users').doc(uid).collection('history');

  Stream<Map<String, dynamic>?> userStream() {
    return firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data());
  }

  Stream<List<MovieModel>> watchlistStream() => moviesStream(watchlistRef);

  Stream<List<MovieModel>> historyStream() => moviesStream(historyRef);

  Stream<List<MovieModel>> moviesStream(
      CollectionReference<Map<String, dynamic>> ref,
      ) {
    return ref.orderBy('addedAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MovieModel.fromSaved(doc.data())).toList();
    });
  }

  Stream<bool> isInWatchlist(int movieId) {
    return watchlistRef.doc('$movieId').snapshots().map((doc) => doc.exists);
  }

  Future<void> toggleWatchlist(MovieModel movie) async {
    final doc = watchlistRef.doc('${movie.id}');
    final snapshot = await doc.get();
    if (snapshot.exists) {
      await doc.delete();
    } else {
      await doc.set(movieToMap(movie));
    }
  }

  Future<void> addToHistory(MovieModel movie) async {
    await historyRef.doc('${movie.id}').set(movieToMap(movie));
  }

  Map<String, dynamic> movieToMap(MovieModel movie) {
    return {
      'id': movie.id,
      'title': movie.title,
      'rating': movie.rating,
      'image': movie.mediumCoverImage,
      'addedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
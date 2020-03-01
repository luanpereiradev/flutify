package br.com.luanpereira.flutify

import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.Player

import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.util.Util

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    companion object {
        const val CHANNEL_ID = "flutify/player"
    }

    private lateinit var player: SimpleExoPlayer

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        // iniciando o player
        player = SimpleExoPlayer.Builder(this).build()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_ID).setMethodCallHandler { call, result ->
            when (call.method) {
                "seekStart" -> {
                    player.playWhenReady = false
                    result.success(true)
                }
                "seekEnd" -> {
                    player.playWhenReady = true
                    result.success(true)
                }
                "seekTo" -> {
                    player.seekTo(call.argument<Double>("value")!!.toLong())
                    result.success(player.playbackState == ExoPlayer.STATE_BUFFERING)
                }
                "getPosition" -> {
                    result.success(player.currentPosition.toDouble())
                }
                "isPlaying" -> {
                    result.success(player.playWhenReady)
                }
                "isBuffering" -> {
                    result.success(player.playbackState == ExoPlayer.STATE_BUFFERING)
                }
                "playPause" -> {
                    if (player.playbackState == ExoPlayer.STATE_ENDED) {
                        player.seekTo(0)
                    }
                    val playing = !player.playWhenReady
                    player.playWhenReady = playing
                    result.success(playing)
                }
                "playUri" -> {
                    if (player.isPlaying) {
                        Log.d("Flutify", "release exo");
                        player.playWhenReady = false
                    }

                    Log.d("Flutify", "STATE: " + player.playbackState);

                    val dataSourceFactory = DefaultDataSourceFactory(applicationContext, Util.getUserAgent(applicationContext, "Flutify"))
                    val audioSource = ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(Uri.parse(call.argument("url")!!))

                    player.prepare(audioSource)
                    player.playWhenReady = true

                    // Aguardar o Exo ficar pronto e responder com a duração.
                    player.addListener(object : Player.EventListener {
                        override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
                            if (playbackState == ExoPlayer.STATE_READY) {
                                result.success(player.duration.toDouble())
                                player.removeListener(this)
                            }
                        }
                    })
                }
                else -> {
                    Log.d("Flutify", "notImplemented");
                    result.notImplemented()
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()

        // removendo o player da memória
        player.release()
    }

}

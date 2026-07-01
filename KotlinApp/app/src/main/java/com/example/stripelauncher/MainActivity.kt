package com.example.stripelauncher

import android.os.Bundle
import androidx.compose.material3.Button
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.example.stripelauncher.ui.theme.StripeLauncherTheme

// MainActivity Class inherits ComponentActivity, ensuring the app launches
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        // This is where your UI is rendered
        setContent {
            StripeLauncherTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->

                    // Column setup
                    androidx.compose.foundation.layout.Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(innerPadding),
                        horizontalAlignment = androidx.compose.ui.Alignment.CenterHorizontally,
                        verticalArrangement = androidx.compose.foundation.layout.Arrangement.Center
                    ) {

                        // Title
                        Text(text = "StripeLauncher")

                        // Button
                        androidx.compose.material3.Button(
                            onClick = {
                                println("Logged: Launch Game is triggered.")
                            }
                        ) {
                            // Button Label
                            Text(text = "Launch RetroArch")
                        }

                    }
                }
            }
        }
    }
}

// Text
@Composable
fun Greeting(name: String, modifier: Modifier = Modifier) {
    Text(
        text = "Initiate launch game",
        modifier = modifier
    )
}


@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    StripeLauncherTheme {
        Greeting("Android")
    }
}
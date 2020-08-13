//SOURCE: https://dotslashnotes.wordpress.com/2013/09/21/how-to-setup-a-bluetooth-connection-between-arduino-and-a-pcmac/

char val; // variable to receive data from the serial port
int ledpin = 13; // Arduino LED pin 13 (on-board LED)
void setup() {
   pinMode(ledpin, OUTPUT); // pin 13 (on-board LED) as OUTPUT
   Serial.begin(9600); // start serial communication at 9600bps

   while (!Serial) {
   ; // wait for serial port to connect. Needed for native USB port only
   }

   Serial.println("ASCII Table ~ Character Map");

}
 
void loop() {

   // Testing sending bluetooth data
   int sensorValue = analogRead(A0);
   Serial.print("Sensor value:");
   Serial.print(sensorValue);
   Serial.print("\n");

   // Testing receiving bluetooth data
   if( Serial.available() ) // if data is available to read
   {
      val = Serial.read(); // read it and store it in 'val'
   }
   if( val == 'H' ) // if 'H' was received
   {
      digitalWrite(ledpin, HIGH); // turn ON the LED
      Serial.print("LED turned ON\n");
   } else {
      digitalWrite(ledpin, LOW); // otherwise turn it OFF
      Serial.print("LED turned OFF\n");
   }
   delay(100); // wait 100ms for next reading
}

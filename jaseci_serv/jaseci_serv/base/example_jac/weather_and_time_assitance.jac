walker weather_and_time_assitance{
    has input_aud="/jaseci-experiment/input_file.mp3";
    has intents = [
        "time",
        "weather"
    ];
    has weather_list=[
        "The current weather is sunny and clear, with a high of 75 degrees Fahrenheit.",
        "It's raining heavily at the moment, with thunderstorms expected to continue throughout the day.",
        "The current weather conditions are extremely hot and humid, with temperatures reaching 95 degrees Fahrenheit.",
        "It's a bit chilly outside, with overcast skies and a chance of scattered showers in the afternoon."
    ];
    can vc_tts.synthesize;
    can bi_enc.infer;
    can stt.transcribe, stt.audio_to_array;
    text=stt.transcribe(language="en", audio_file=input_aud);
    pred_intent=bi_enc.infer([text], intents, "text", "text")[0]["predicted"];
    if(pred_intent["label"]=="time"){
        inp_text="The time is " + std.time_now().str::split("T")[1].str::split(".")[0].str;
    }
    elif(pred_intent["label"]=="weather"){
        inp_text = rand.choice(weather_list);
    }
    else{
        inp_text="Sorry, i can only hand queries on weather and time";
    }
    out_aud=vc_tts.synthesize(input_text=inp_text, speaker= "female",save_path="./");
    file.delete(out_aud["file_path"]);
    report out_aud;
    // report inp_text;
}
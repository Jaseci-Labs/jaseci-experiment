walker predict_bboxes {
    has anchor preds;
    has images;
    can yolos.detect_batch;
    can file.load_to_b64;

    with entry {
        if (!images): images = ['data/person_street_walking.webp', 'data/small_image_person.jpg'];
        images_bs64 = [];
        for image in images {
            images_bs64.l::append(file.load_to_b64(image));
        }
        images = images_bs64;
    }

    preds = yolos.detect_batch(images=images, b64=true);
}

walker get_video_explanation {
    has preds;
    has anchor explanation;
    can gpt2.generate;

    query = "These are the objects found in the video in each frame. ";
    query = query + spawn here walker::get_detection_str(preds=preds);
    query = query + " What is the video about?";
    explanation = gpt2.generate(text=query, max_length=200, num_return_sequences=10);
}

walker get_detection_str {
    has anchor s = "";
    has preds;

    for i=0 to i<preds.length by i+=1 {
        s = s + "In frame " + i.str + " ";
        for bbox in preds[i] {
            s = s + bbox["label"] + " is detected, ";
        }
        s = s + ".";
    }
}

walker vision_llm {
    has explanation;
    has images = [];

    root {
        preds = spawn here walker::predict_bboxes(images=images);
        explanation = spawn here walker::get_video_explanation(preds=preds);
        report explanation;
    }
}

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
      "Connection": "keep-alive",
    },
  });
}

function numberValue(value: unknown, fallback: number, min: number, max: number) {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) return fallback;
  return Math.max(min, Math.min(max, Math.round(parsed)));
}

function stripCodeFence(text: string) {
  return text
    .trim()
    .replace(/^```json\s*/i, "")
    .replace(/^```\s*/i, "")
    .replace(/```$/i, "")
    .trim();
}

function makePrompt(action: string, body: Record<string, unknown>) {
  const subject = String(body.subject ?? "General subject");
  const topic = String(body.topic ?? "General topic");
  const difficulty = String(body.difficulty ?? "medium");
  const count = numberValue(body.count, 10, 1, 50);
  const maxScore = numberValue(body.maxScore, 10, 1, 100);
  const rule = "Return only valid JSON. Use concise, teacher-friendly language.";

  if (action === "generate_flashcards") {
    return `${rule} Create ${count} ${difficulty} flashcards for ${subject}, topic: ${topic}. JSON shape: {"flashcards":[{"front":"","back":"","difficulty":"easy|medium|hard"}]}`;
  }

  if (action === "generate_exam") {
    return `${rule} Create a ${count}-item ${difficulty} exam for ${subject}, topic: ${topic}. Use multiple-choice questions. JSON shape: {"title":"","description":"","passing_score":75,"time_limit":30,"questions":[{"type":"multiple_choice","question":"","choices":["","","",""],"answer":"","points":1}]}`;
  }

  if (action === "analyze_results") {
    return `${rule} Analyze this result data for ${subject}. Data: ${JSON.stringify(body.resultData ?? {})}. JSON shape: {"summary":"","strengths":[""],"weak_topics":[""],"recommendations":[""],"risk_level":"low|medium|high"}`;
  }

  return `${rule} Review this written answer for ${subject}. Question: ${JSON.stringify(body.question ?? "")}. Answer: ${JSON.stringify(body.answer ?? "")}. Rubric: ${JSON.stringify(body.rubric ?? "accuracy, completeness, clarity")}. Max score: ${maxScore}. JSON shape: {"suggested_score":0,"max_score":${maxScore},"feedback":"","rubric_breakdown":[{"criterion":"","score":0,"max":0,"comment":""}],"teacher_review_required":true}`;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  const apiKey = Deno.env.get("GEMINI_API_KEY");
  const model = Deno.env.get("GEMINI_MODEL") ?? "gemini-2.0-flash";

  if (!apiKey) {
    return jsonResponse({
      error: "AI is not configured yet. Add GEMINI_API_KEY in Supabase secrets.",
      setup_command: "supabase secrets set GEMINI_API_KEY=your_key_here",
    }, 503);
  }

  const body = await req.json();
  const action = String(body.action ?? "");
  const allowed = ["generate_flashcards", "generate_exam", "analyze_results", "check_essay"];
  if (!allowed.includes(action)) return jsonResponse({ error: "Invalid AI action" }, 400);

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ role: "user", parts: [{ text: makePrompt(action, body) }] }],
        generationConfig: { temperature: action === "check_essay" ? 0.2 : 0.7 },
      }),
    },
  );

  const providerBody = await response.json();
  if (!response.ok) return jsonResponse({ error: "AI provider error", details: providerBody }, response.status);

  const text = providerBody?.candidates?.[0]?.content?.parts?.[0]?.text;
  if (typeof text !== "string") return jsonResponse({ error: "AI returned no text" }, 502);

  try {
    return jsonResponse({ success: true, action, result: JSON.parse(stripCodeFence(text)) });
  } catch (_) {
    return jsonResponse({ success: false, action, raw: text, error: "AI returned invalid JSON" }, 502);
  }
});

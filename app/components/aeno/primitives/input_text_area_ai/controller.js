import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "textarea",
    "aiButton",
    "buttonIcon",
    "buttonSpinner",
    "buttonLabel",
    "streamingIndicator"
  ];

  static values = {
    aiUrl: String,
    aiPrompt: String,
    systemPrompts: { type: Array, default: [] },
    model: String,
    aiButtonLabel: { type: String, default: "AI Assist" },
    generating: { type: Boolean, default: false }
  };

  connect() {
    this.abortController = null;
  }

  disconnect() {
    this.cancelGeneration();
  }

  async generateAi() {
    if (this.generatingValue) {
      this.cancelGeneration();
      return;
    }

    const currentText = this.textareaTarget.value;

    const prompt = this.aiPromptValue
      ? this.aiPromptValue.replace("{{content}}", currentText)
      : currentText;

    if (!prompt.trim()) {
      this.textareaTarget.focus();
      return;
    }

    this.startGenerating();

    try {
      this.abortController = new AbortController();

      const body = {
        prompt: prompt
      };

      if (this.systemPromptsValue.length > 0) {
        body.system_prompts = this.systemPromptsValue;
      }

      if (this.modelValue) {
        body.model = this.modelValue;
      }

      const response = await fetch(this.aiUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "text/event-stream",
          "X-CSRF-Token": this.csrfToken()
        },
        body: JSON.stringify(body),
        signal: this.abortController.signal
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const contentType = response.headers.get("content-type");

      if (contentType?.includes("text/event-stream") || contentType?.includes("application/x-ndjson")) {
        await this.handleStreamingResponse(response);
      } else {
        await this.handleJsonResponse(response);
      }

    } catch (error) {
      if (error.name === "AbortError") {
        console.log("Generation cancelled");
      } else {
        console.error("AI generation failed:", error);
        this.dispatch("error", { detail: { message: error.message } });
      }
    } finally {
      this.stopGenerating();
    }
  }

  async handleStreamingResponse(response) {
    const reader = response.body.getReader();
    const decoder = new TextDecoder();

    const originalContent = this.textareaTarget.value;
    const separator = originalContent.trim() ? "\n\n" : "";
    let generatedContent = "";

    try {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value, { stream: true });
        const lines = chunk.split("\n");

        for (const line of lines) {
          if (line.startsWith("data: ")) {
            const data = line.slice(6);

            if (data === "[DONE]") {
              continue;
            }

            try {
              const parsed = JSON.parse(data);
              const content = parsed.content || parsed.text || parsed.delta?.content || "";

              if (content) {
                generatedContent += content;
                this.textareaTarget.value = originalContent + separator + generatedContent;
                this.scrollTextareaToBottom();
              }
            } catch {
              if (data.trim() && data !== "[DONE]") {
                generatedContent += data;
                this.textareaTarget.value = originalContent + separator + generatedContent;
                this.scrollTextareaToBottom();
              }
            }
          }
        }
      }
    } catch (error) {
      if (error.name !== "AbortError") {
        throw error;
      }
    }

    this.dispatch("complete", { detail: { content: generatedContent } });
  }

  async handleJsonResponse(response) {
    const data = await response.json();
    const content = data.content || data.text || data.response || "";

    if (content) {
      const originalContent = this.textareaTarget.value;
      const separator = originalContent.trim() ? "\n\n" : "";
      this.textareaTarget.value = originalContent + separator + content;
      this.dispatch("complete", { detail: { content } });
    }
  }

  cancelGeneration() {
    if (this.abortController) {
      this.abortController.abort();
      this.abortController = null;
    }
  }

  startGenerating() {
    this.generatingValue = true;
    this.aiButtonTarget.disabled = false;
    this.buttonIconTarget.classList.add("hidden");
    this.buttonSpinnerTarget.classList.remove("hidden");
    this.buttonLabelTarget.textContent = "Cancel";
    this.streamingIndicatorTarget.classList.remove("hidden");
    this.textareaTarget.readOnly = true;
  }

  stopGenerating() {
    this.generatingValue = false;
    this.aiButtonTarget.disabled = false;
    this.buttonIconTarget.classList.remove("hidden");
    this.buttonSpinnerTarget.classList.add("hidden");
    this.buttonLabelTarget.textContent = this.aiButtonLabelValue;
    this.streamingIndicatorTarget.classList.add("hidden");
    this.textareaTarget.readOnly = false;
    this.abortController = null;
  }

  scrollTextareaToBottom() {
    this.textareaTarget.scrollTop = this.textareaTarget.scrollHeight;
  }

  csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || "";
  }
}

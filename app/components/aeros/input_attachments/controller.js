import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "dropzone",
    "fileInput",
    "previewsContainer",
    "hiddenInputs",
    "progressContainer",
    "progressBar",
    "progressText"
  ];

  static values = {
    accept: { type: String, default: "*/*" },
    maxFiles: Number,
    maxSize: Number,
    attachments: { type: Array, default: [] },
    directUploadUrl: String
  };

  connect() {
    this.dragCounter = 0;
    this.renderPreviews();
    this.renderHiddenInputs();
  }

  triggerFileInput() {
    this.fileInputTarget.click();
  }

  onDragOver(event) {
    event.preventDefault();
    event.stopPropagation();
    this.dragCounter++;
    this.dropzoneTarget.classList.add("border-indigo-400", "bg-indigo-50");
  }

  onDragLeave(event) {
    event.preventDefault();
    event.stopPropagation();
    this.dragCounter--;
    if (this.dragCounter === 0) {
      this.dropzoneTarget.classList.remove("border-indigo-400", "bg-indigo-50");
    }
  }

  onDrop(event) {
    event.preventDefault();
    event.stopPropagation();
    this.dragCounter = 0;
    this.dropzoneTarget.classList.remove("border-indigo-400", "bg-indigo-50");

    const files = Array.from(event.dataTransfer.files);
    this.handleFiles(files);
  }

  onFileSelect(event) {
    const files = Array.from(event.target.files);
    this.handleFiles(files);
    event.target.value = "";
  }

  handleFiles(files) {
    const validFiles = files.filter(file => this.validateFile(file));

    if (this.maxFilesValue) {
      const remaining = this.maxFilesValue - this.attachmentsValue.length;
      if (validFiles.length > remaining) {
        alert(`You can only add ${remaining} more file(s).`);
        validFiles.splice(remaining);
      }
    }

    if (validFiles.length === 0) return;

    if (this.directUploadUrlValue) {
      this.uploadFiles(validFiles);
    } else {
      this.addFilesLocally(validFiles);
    }
  }

  validateFile(file) {
    if (this.maxSizeValue && file.size > this.maxSizeValue) {
      alert(`File "${file.name}" is too large. Maximum size is ${this.formatBytes(this.maxSizeValue)}.`);
      return false;
    }

    if (this.acceptValue !== "*/*") {
      const acceptedTypes = this.acceptValue.split(",").map(t => t.trim());
      const fileType = file.type;
      const fileExt = "." + file.name.split(".").pop().toLowerCase();

      const isAccepted = acceptedTypes.some(accepted => {
        if (accepted.startsWith(".")) {
          return fileExt === accepted.toLowerCase();
        }
        if (accepted.endsWith("/*")) {
          return fileType.startsWith(accepted.replace("/*", "/"));
        }
        return fileType === accepted;
      });

      if (!isAccepted) {
        alert(`File "${file.name}" is not an accepted file type.`);
        return false;
      }
    }

    return true;
  }

  async uploadFiles(files) {
    this.showProgress();

    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      const progress = ((i / files.length) * 100).toFixed(0);
      this.updateProgress(progress);

      try {
        const signedId = await this.uploadFile(file);
        const url = URL.createObjectURL(file);

        this.attachmentsValue = [
          ...this.attachmentsValue,
          {
            id: signedId,
            url: url,
            filename: file.name,
            position: this.attachmentsValue.length,
            isNew: true
          }
        ];
      } catch (error) {
        console.error(`Failed to upload ${file.name}:`, error);
        alert(`Failed to upload "${file.name}".`);
      }
    }

    this.hideProgress();
    this.renderPreviews();
    this.renderHiddenInputs();
    this.dispatch("change", { detail: { attachments: this.attachmentsValue } });
  }

  async uploadFile(file) {
    return new Promise((resolve, reject) => {
      const formData = new FormData();
      formData.append("file", file);

      const xhr = new XMLHttpRequest();
      xhr.open("POST", this.directUploadUrlValue);
      xhr.setRequestHeader("Accept", "application/json");
      xhr.setRequestHeader("X-CSRF-Token", this.csrfToken());

      xhr.upload.addEventListener("progress", (event) => {
        if (event.lengthComputable) {
          const progress = ((event.loaded / event.total) * 100).toFixed(0);
          this.updateProgress(progress);
        }
      });

      xhr.addEventListener("load", () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          const response = JSON.parse(xhr.responseText);
          resolve(response.signed_id || response.id);
        } else {
          reject(new Error(`Upload failed: ${xhr.status}`));
        }
      });

      xhr.addEventListener("error", () => reject(new Error("Upload failed")));
      xhr.send(formData);
    });
  }

  addFilesLocally(files) {
    files.forEach(file => {
      const url = URL.createObjectURL(file);
      const tempId = `temp_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

      this.attachmentsValue = [
        ...this.attachmentsValue,
        {
          id: tempId,
          url: url,
          filename: file.name,
          position: this.attachmentsValue.length,
          file: file,
          isNew: true
        }
      ];
    });

    this.renderPreviews();
    this.renderHiddenInputs();
    this.dispatch("change", { detail: { attachments: this.attachmentsValue } });
  }

  removeAttachment(event) {
    const index = parseInt(event.currentTarget.dataset.index, 10);
    const attachment = this.attachmentsValue[index];

    if (attachment?.url?.startsWith("blob:")) {
      URL.revokeObjectURL(attachment.url);
    }

    this.attachmentsValue = this.attachmentsValue.filter((_, i) => i !== index);
    this.reorderPositions();
    this.renderPreviews();
    this.renderHiddenInputs();
    this.dispatch("change", { detail: { attachments: this.attachmentsValue } });
  }

  reorderPositions() {
    this.attachmentsValue = this.attachmentsValue.map((att, idx) => ({
      ...att,
      position: idx
    }));
  }

  onDragStartPreview(event) {
    event.dataTransfer.effectAllowed = "move";
    event.dataTransfer.setData("text/plain", event.currentTarget.dataset.index);
    event.currentTarget.classList.add("opacity-50");
  }

  onDragEndPreview(event) {
    event.currentTarget.classList.remove("opacity-50");
  }

  onDragOverPreview(event) {
    event.preventDefault();
    event.dataTransfer.dropEffect = "move";
  }

  onDropPreview(event) {
    event.preventDefault();
    const fromIndex = parseInt(event.dataTransfer.getData("text/plain"), 10);
    const toIndex = parseInt(event.currentTarget.dataset.index, 10);

    if (fromIndex === toIndex) return;

    const attachments = [...this.attachmentsValue];
    const [moved] = attachments.splice(fromIndex, 1);
    attachments.splice(toIndex, 0, moved);

    this.attachmentsValue = attachments.map((att, idx) => ({
      ...att,
      position: idx
    }));

    this.renderPreviews();
    this.renderHiddenInputs();
    this.dispatch("change", { detail: { attachments: this.attachmentsValue } });
  }

  renderPreviews() {
    const html = this.attachmentsValue.map((attachment, index) => {
      const isImage = this.isImageFile(attachment.filename || attachment.url);

      return `
        <div class="relative group rounded-lg border border-gray-200 overflow-hidden bg-gray-50 aspect-square cursor-move"
             draggable="true"
             data-index="${index}"
             data-action="dragstart->${this.identifier}#onDragStartPreview dragend->${this.identifier}#onDragEndPreview dragover->${this.identifier}#onDragOverPreview drop->${this.identifier}#onDropPreview">
          ${isImage
            ? `<img src="${attachment.url}" alt="${this.escapeHtml(attachment.filename)}" class="w-full h-full object-cover">`
            : `<div class="w-full h-full flex flex-col items-center justify-center p-2">
                <svg class="h-8 w-8 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
                </svg>
                <span class="mt-1 text-xs text-gray-500 truncate max-w-full">${this.escapeHtml(attachment.filename)}</span>
              </div>`
          }
          <button type="button"
                  class="absolute top-1 right-1 p-1 bg-white rounded-full shadow-sm opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-50"
                  data-index="${index}"
                  data-action="click->${this.identifier}#removeAttachment">
            <svg class="h-4 w-4 text-gray-500 hover:text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
          <div class="absolute bottom-1 left-1 px-1.5 py-0.5 bg-black/50 rounded text-[10px] text-white">
            ${index + 1}
          </div>
        </div>
      `;
    }).join("");

    this.previewsContainerTarget.innerHTML = html;
  }

  renderHiddenInputs() {
    const baseName = this.element.dataset[`${this.identifier.replace(/-/g, "")}Name`] ||
                     this.element.querySelector("[name]")?.name?.replace(/\[\]$/, "") ||
                     "attachments";

    const html = this.attachmentsValue.map((attachment, index) => {
      if (attachment.file) {
        return "";
      }
      return `<input type="hidden" name="${baseName}[${index}][id]" value="${attachment.id}">
              <input type="hidden" name="${baseName}[${index}][position]" value="${index}">`;
    }).join("");

    this.hiddenInputsTarget.innerHTML = html;
  }

  isImageFile(filename) {
    if (!filename) return false;
    const ext = filename.split(".").pop().toLowerCase();
    return ["jpg", "jpeg", "png", "gif", "webp", "svg", "bmp"].includes(ext);
  }

  showProgress() {
    if (this.hasProgressContainerTarget) {
      this.progressContainerTarget.classList.remove("hidden");
    }
  }

  hideProgress() {
    if (this.hasProgressContainerTarget) {
      this.progressContainerTarget.classList.add("hidden");
    }
  }

  updateProgress(percent) {
    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${percent}%`;
    }
    if (this.hasProgressTextTarget) {
      this.progressTextTarget.textContent = `${percent}%`;
    }
  }

  formatBytes(bytes) {
    if (bytes === 0) return "0 Bytes";
    const k = 1024;
    const sizes = ["Bytes", "KB", "MB", "GB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
  }

  escapeHtml(text) {
    if (!text) return "";
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  }

  csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || "";
  }
}

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["vote", "confirmCount", "contestCount"];

  connect() {
    console.log("Vote controller connected");
    console.log(this.voteTarget);
  }

  updateVote(event) {
    event.preventDefault();
    const url = event.currentTarget.href;

    fetch(url, {
      method: "POST",
      headers: {
        "Accept": "text/html", // Demande une réponse HTML pour Turbo
      },
    })
      .then(response => response.text())
      .then(html => {
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, "text/html");
        const newConfirmCount = doc.querySelector("[data-votes-target='confirmCount']").textContent;
        const newContestCount = doc.querySelector("[data-votes-target='contestCount']").textContent;

        this.confirmCountTarget.textContent = newConfirmCount;
        this.contestCountTarget.textContent = newContestCount;

        // Mise à jour des classes et textes des boutons si nécessaire
        this.updateButtonStates(event.currentTarget);
      })
      .catch(error => console.error("Erreur lors de la mise à jour des votes :", error));
  }

  updateButtonStates(button) {
    if (button.classList.contains("confirm-button")) {
      if (!button.classList.contains("voted")) {
        button.classList.add("voted");
        button.querySelector("span").previousSibling.textContent = "Confirmé";
      }
    } else if (button.classList.contains("contest-button")) {
      if (!button.classList.contains("voted")) {
        button.classList.add("voted");
        button.querySelector("span").previousSibling.textContent = "Contesté";
      }
    }
  }
}

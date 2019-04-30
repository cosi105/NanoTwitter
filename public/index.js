window.onload = () => {
  newTweetButton = document.getElementById("new-tweet");
  // Clicking on New Tweet button/icon
  newTweetButton.addEventListener("click", event => {
    window.location.href = "/tweets/new";
  });
};

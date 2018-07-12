const handleClick = (checkbox) => {
  let input = checkbox.querySelector(".checkbox")
  if (input.checked) {
    input.checked = false
  } else {
    input.checked = true
  }
  checkbox.classList.toggle("active")
}

const checkIfCanGenerate = (array) => {
  const button = document.getElementById("btn-js");
  // console.log(button)
  const min = 2;
  const max = 10;
  let numberOfChecked = 0;
  array.forEach((checkbox) => {
    let input = checkbox.querySelector(".checkbox")
    if (input.checked == true) {
      numberOfChecked += 1
    }
  });
  console.log(numberOfChecked > min)
  if (numberOfChecked < min) {
    button.classList.add("disabled");
    button.disabled = true
    button.value = "SELECT AT LEAST 2 ARTISTS"
  } else if (numberOfChecked > max){
    button.classList.add("disabled");
    button.disabled = true
    button.value = "NO MORE THAN 10 ARTISTS"
  } else {
    button.classList.remove("disabled");
    button.disabled = false
    button.value = "GENERATE PLAYLIST"
  }
}

const checkboxes = document.querySelectorAll(".artist-checkbox-js");

checkboxes.forEach((checkbox) => {
  checkbox.addEventListener("click",(e) => {
    e.preventDefault();
    handleClick(checkbox);
    checkIfCanGenerate(checkboxes);
  });
});


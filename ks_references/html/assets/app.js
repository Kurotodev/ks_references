$('.container').hide();
function TriggerCallback(event, data) {
	data.name = event;
	return $.post(
		`https://${GetParentResourceName()}/TriggerCallback`,
		JSON.stringify(data)
	).promise();
}
document.addEventListener('keydown', function(event) {
    if (event.key === "Escape") {
 	   $('.container').hide();
        $.post(`https://${GetParentResourceName()}/close`)
    }
});


window.addEventListener('message', function(event) {
    
    if (event.data.type === 'copy') {
      var node = document.createElement('textarea');
      var selection = document.getSelection();

      node.textContent = event.data.data;
      document.body.appendChild(node);

      selection.removeAllRanges();
      node.select();
      document.execCommand('copy');
      document.getElementById('code').placeholder = "Codigo copiado con exito.";

      selection.removeAllRanges();
      document.body.removeChild(node);

    }
    if (event.data.type === 'show') {
		$('.container').show();
	}
    if (event.data.type === 'setcode') {
        $('#refcode').text(event.data.code);
        $('#usecode').text(event.data.use);
    }
});
document.getElementById('copyRef').onclick = () => {
   let code = document.getElementById('refcode').textContent;
   $.post(`https://${GetParentResourceName()}/copy` , JSON.stringify({
    code : code
   }));

};

document.getElementById('claim').onclick = () => {
        let code = document.getElementById('code').value.trim().replace(/\s+/g, '');
        
        if (!code) {
            document.getElementById('code').placeholder = "Por favor, escribe un código de referido.";
            return;
        }

		TriggerCallback('ks_referencias:claim', {
			code: code,
		}).done((cb) => {
		if (cb) {
            document.getElementById('code').placeholder = cb;
            document.getElementById('code').value = "";
        } else {
            document.getElementById('code').placeholder = "Código inválido.";
        }

    });
};




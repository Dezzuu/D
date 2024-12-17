$(document).ready(function () {
    let generatedCode = null;

    function generateRandomCode() {
        return Math.floor(Math.random() * (9999999999 - 1111111111 + 1)) + 1111111111;
    }

    function checkWinCondition() {
        let isWin = true;
        $('.s').each((index, element) => {
            const currentDigit = parseInt($(element).text(), 10);
            const targetDigit = parseInt(String(generatedCode)[index], 10);
            if (currentDigit !== targetDigit) {
                isWin = false;
            }
        });

        if (isWin) {
            $('.box').fadeOut(500, () => {
                $.post('https://Dezzu_shoprobbery/reward', JSON.stringify({}));
                $.post('https://Dezzu_shoprobbery/close', JSON.stringify({}));
            });
        }
    }

    function updateDigitEffect(index, currentDigit) {
        const targetDigit = parseInt(String(generatedCode)[index], 10);
        const digitElement = $(`.s:eq(${index})`);
        if (currentDigit === targetDigit) {
            digitElement.addClass('highlight'); 
        } else {
            digitElement.removeClass('highlight'); 
        }
    }

    window.addEventListener('message', (event) => {
        const { action, duration, code } = event.data || {};

        if (action === 'open') {
            $('.box').fadeIn(500).css('display', 'block');
            proggres(duration);

            generatedCode = code || generateRandomCode();

            $('.s').text('0').removeClass('highlight'); 
        }
    });

    $(".p").click(function () {
        const id = $(this).attr("id");
        const sumaElement = $(`.s[id='${id}']`);
        const suma = parseInt(sumaElement.text());

        if (!isNaN(suma) && suma < 9) {
            const newDigit = suma + 1;
            sumaElement.text(newDigit);

            updateDigitEffect(parseInt(id) - 1, newDigit);
            checkWinCondition();
        }
    });

    $(".m").click(function () {
        const id = $(this).attr("id");
        const sumaElement = $(`.s[id='${id}']`);
        const suma = parseInt(sumaElement.text());

        if (!isNaN(suma) && suma > 0) {
            const newDigit = suma - 1;
            sumaElement.text(newDigit);

            updateDigitEffect(parseInt(id) - 1, newDigit);
            checkWinCondition();
        }
    });

    function proggres(duration) {
        let proggres = 0;
        const startTime = performance.now();

        const animation = () => {
            const time = performance.now() - startTime;
            proggres = Math.min((time / duration) * 100, 100);
            $('.proggres').css('width', proggres + '%');

            if (proggres >= 100) {
                $('.box').fadeOut(500, () => {
                    $.post('https://Dezzu_shoprobbery/close', JSON.stringify({}));
                });
            } else {
                requestAnimationFrame(animation);
            }
        };
        animation();
    }
});

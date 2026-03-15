$(document).ready(function () {
    window.addEventListener('message', function (event) {
        let data = event.data;
        if (data.action === "show") {
            if (data.themeColor) {
                document.documentElement.style.setProperty('--primary-color', data.themeColor);
                const rgb = colorToRgb(data.themeColor);
                if (rgb) {
                    document.documentElement.style.setProperty('--primary-rgb', `${rgb.r}, ${rgb.g}, ${rgb.b}`);
                    document.documentElement.style.setProperty('--primary-glow', `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 0.4)`);
                    document.documentElement.style.setProperty('--border-card', `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 0.5)`);
                }
            }
            $("#ui-wrapper").fadeIn(300);
            $("#clothing-menu").addClass("menu-active");
            if (data.activeItems) {
                updateButtonStates(data.activeItems);
            }
            drawBranchLines();
        } else if (data.action === "hide") {
            $("#ui-wrapper").fadeOut(300);
            $("#clothing-menu").removeClass("menu-active");
        } else if (data.action === "updateButtons") {
            updateButtonStates(data.activeItems);
        } else if (data.action === "updateBoneCoords") {
            drawBranchLines(data.coords);
        }
    });

    document.onkeyup = function (data) {
        if (data.which == 27) { // ESC
            $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({}));
        }
    };

    $(".item-button").click(function () {
        let type = $(this).data("type");
        let active = $(this).hasClass("active");

        $.post(`https://${GetParentResourceName()}/toggleItem`, JSON.stringify({
            type: type,
            active: !active
        }));
    });

    $(".reset-button").click(function () {
        $.post(`https://${GetParentResourceName()}/reset`, JSON.stringify({}));
    });

    function updateButtonStates(activeItems) {
        $(".item-button").removeClass("active");
        for (let type in activeItems) {
            if (activeItems[type]) {
                $(`.item-button[data-type="${type}"]`).addClass("active");
            }
        }
    }

    function drawBranchLines(boneCoords) {
        if (!boneCoords) return;
        const linePath = document.getElementById('branch-path');
        const dotsPath = document.getElementById('branch-dots');
        let dLines = "";
        let dDots = "";

        const menuCards = document.querySelectorAll('.category-card');
        const screenWidth = window.innerWidth;
        const screenHeight = window.innerHeight;

        menuCards.forEach((card) => {
            const rowId = card.dataset.row;
            const target = boneCoords[rowId];
            if (!target) return;

            const label = card.querySelector('.row-label');
            const rect = label.getBoundingClientRect();

            const startX = (rect.right / screenWidth) * 100;
            const startY = (rect.top + rect.height / 2) / screenHeight * 100;

            const endX = target.x;
            const endY = target.y;

            const cp1X = startX + (endX - startX) * 0.4;
            const cp1Y = startY;
            const cp2X = startX + (endX - startX) * 0.6;
            const cp2Y = endY;

            dLines += `M ${startX},${startY} C ${cp1X},${cp1Y} ${cp2X},${cp2Y} ${endX},${endY} `;

            // Dot at bone position (small and professional) - separate for filling
            dDots += `M ${endX},${endY} m -0.4,0 a 0.4,0.4 0 1,1 0.8,0 a 0.4,0.4 0 1,1 -0.8,0 `;

            // Junction dot at label (0.2 radius) - separate for filling
            dDots += `M ${startX},${startY} m -0.2,0 a 0.2,0.2 0 1,1 0.4,0 a 0.2,0.2 0 1,1 -0.4,0 `;
        });

        linePath.setAttribute('d', dLines);
        dotsPath.setAttribute('d', dDots);
    }
    function colorToRgb(color) {
        const dummy = document.createElement('div');
        dummy.style.color = color;
        document.body.appendChild(dummy);
        const computed = window.getComputedStyle(dummy).color;
        document.body.removeChild(dummy);
        const match = computed.match(/\d+/g);
        return match ? { r: match[0], g: match[1], b: match[2] } : null;
    }
});

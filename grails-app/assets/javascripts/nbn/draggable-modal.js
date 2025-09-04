function makeModalDraggable(modalSelector) {
    const dialog = document.querySelector(modalSelector + ' .modal-dialog');
    const header = dialog.querySelector('.modal-header');

    let dragging = false, offsetX = 0, offsetY = 0;

    header.style.cursor = 'grab';

    header.addEventListener('mousedown', (e) => {
        if (e.button && e.button !== 0) return;

        // Freeze current on-screen position the *first* time we drag
        if (!dialog.dataset.dragReady) {
            const rect = dialog.getBoundingClientRect();

            // Prevent re-centering/resize when we switch positioning
            dialog.style.width = rect.width + 'px';
            dialog.style.margin = 0;
            dialog.style.transform = 'none';

            // Use fixed so left/top match viewport coordinates from getBoundingClientRect()
            dialog.style.position = 'fixed';
            dialog.style.left = rect.left + 'px';
            dialog.style.top  = rect.top  + 'px';

            dialog.dataset.dragReady = '1';
        }

        dragging = true;
        header.style.cursor = 'grabbing';

        // Compute drag offsets from the *current* fixed left/top
        const left = parseFloat(dialog.style.left) || 0;
        const top  = parseFloat(dialog.style.top)  || 0;
        offsetX = e.clientX - left;
        offsetY = e.clientY - top;

        e.preventDefault();
    });

    document.addEventListener('mousemove', (e) => {
        if (!dragging) return;
        dialog.style.left = (e.clientX - offsetX) + 'px';
        dialog.style.top  = (e.clientY - offsetY) + 'px';
    });

    document.addEventListener('mouseup', () => {
        if (!dragging) return;
        dragging = false;
        header.style.cursor = 'grab';
    });
}


// initialise once the modal exists in DOM:
//makeModalDraggable('#myModal');

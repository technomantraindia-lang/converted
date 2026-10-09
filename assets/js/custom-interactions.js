/**
 * Proventus Value Tech - Complete Navigation and UI Handler
 */

document.addEventListener('DOMContentLoaded', function () {
    initNavigation();
    initCounters();
    initCopyrightYear();
    initSmoothScroll();
    initScrollToTop();
    initProjectFilters();
});

function initNavigation() {
    // 1. Mobile Menu Burger Toggle
    var menuToggles = document.querySelectorAll('.elementor-menu-toggle');
    menuToggles.forEach(function (toggle) {
        toggle.addEventListener('click', function (e) {
            e.preventDefault();
            e.stopPropagation();
            
            var parentWidget = toggle.closest('.elementor-widget-nav-menu') || document.querySelector('.elementor-widget-nav-menu');
            if (parentWidget) {
                var dropdown = parentWidget.querySelector('.elementor-nav-menu--dropdown.elementor-nav-menu__container');
                if (dropdown) {
                    var isExpanded = toggle.getAttribute('aria-expanded') === 'true';
                    toggle.setAttribute('aria-expanded', !isExpanded);
                    toggle.classList.toggle('elementor-active');
                    dropdown.classList.toggle('elementor-active');
                    dropdown.classList.toggle('show-mobile-menu');
                }
            }
        });
    });

    // Close mobile menu if clicked outside
    document.addEventListener('click', function (e) {
        if (!e.target.closest('.elementor-widget-nav-menu')) {
            var activeToggles = document.querySelectorAll('.elementor-menu-toggle.elementor-active');
            activeToggles.forEach(function (t) {
                t.classList.remove('elementor-active');
                t.setAttribute('aria-expanded', 'false');
            });
            var activeDropdowns = document.querySelectorAll('.elementor-nav-menu--dropdown.show-mobile-menu, .elementor-nav-menu--dropdown.elementor-active');
            activeDropdowns.forEach(function (d) {
                d.classList.remove('show-mobile-menu');
                d.classList.remove('elementor-active');
            });
        }
    });

    // 2. Dropdown Menu & Service Mega Menu Behavior
    var hasChildrenItems = document.querySelectorAll('.menu-item-has-children');
    hasChildrenItems.forEach(function (item) {
        var parentLink = item.querySelector('> a');

        if (parentLink) {
            parentLink.addEventListener('click', function (e) {
                var href = parentLink.getAttribute('href');
                // On mobile / small screens, toggle submenu accordion on touch
                if (window.innerWidth <= 1024) {
                    if (item.querySelector('.sub-menu')) {
                        e.preventDefault();
                        e.stopPropagation();
                        item.classList.toggle('sub-menu-open');
                        item.classList.toggle('menu-open');
                    }
                } else {
                    // On desktop, clicking parent navigates directly if valid link
                    if (href && href !== '#' && href !== '') {
                        window.location.href = href;
                    }
                }
            });
        }

        // Desktop mouseenter / mouseleave
        item.addEventListener('mouseenter', function () {
            if (window.innerWidth > 1024) {
                item.classList.add('menu-open');
            }
        });

        item.addEventListener('mouseleave', function () {
            if (window.innerWidth > 1024) {
                item.classList.remove('menu-open');
            }
        });
    });

    // 3. Submenu navigation safety
    var allSubLinks = document.querySelectorAll('.mega-dropdown-wrapper a, .sub-menu a, .elementor-sub-item');
    allSubLinks.forEach(function (link) {
        link.addEventListener('click', function (e) {
            var target = link.getAttribute('href');
            if (target && target !== '#' && !target.startsWith('javascript:')) {
                window.location.href = target;
            }
        });
    });
}

function initScrollToTop() {
    var btn = document.getElementById('scroll-to-top');
    if (!btn) return;

    window.addEventListener('scroll', function () {
        if (window.scrollY > 300) {
            btn.classList.add('visible');
        } else {
            btn.classList.remove('visible');
        }
    }, { passive: true });

    btn.addEventListener('click', function (e) {
        e.preventDefault();
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });
}

function initCounters() {
    var counters = document.querySelectorAll('.elementor-counter-number');
    if ('IntersectionObserver' in window && counters.length > 0) {
        var counterObserver = new IntersectionObserver(function (entries, observer) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting) {
                    var el = entry.target;
                    var targetNum = parseInt(el.getAttribute('data-to-value') || el.innerText.replace(/[^0-9]/g, ''), 10);
                    var duration = parseInt(el.getAttribute('data-duration') || '2000', 10);
                    
                    if (!isNaN(targetNum) && targetNum > 0) {
                        var startTime = null;
                        function animate(currentTime) {
                            if (!startTime) startTime = currentTime;
                            var progress = Math.min((currentTime - startTime) / duration, 1);
                            var currentVal = Math.floor(progress * targetNum);
                            el.innerText = currentVal;
                            if (progress < 1) {
                                requestAnimationFrame(animate);
                            } else {
                                el.innerText = targetNum;
                            }
                        }
                        requestAnimationFrame(animate);
                    }
                    observer.unobserve(el);
                }
            });
        }, { threshold: 0.2 });

        counters.forEach(function (counter) {
            counterObserver.observe(counter);
        });
    }
}

function initCopyrightYear() {
    var copyrightTexts = document.querySelectorAll('.elementor-widget-text-editor p');
    var currentYear = new Date().getFullYear();
    copyrightTexts.forEach(function (p) {
        if (p.innerHTML.indexOf('[year]') !== -1) {
            p.innerHTML = p.innerHTML.replace(/\[year\]/g, currentYear);
        }
    });
}

function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]:not([href="#"]):not([href="#content"])').forEach(function (anchor) {
        anchor.addEventListener('click', function (e) {
            var targetId = this.getAttribute('href');
            var targetEl = document.querySelector(targetId);
            if (targetEl) {
                e.preventDefault();
                targetEl.scrollIntoView({ behavior: 'smooth' });
            }
        });
    });
}

function initProjectFilters() {
    var filterBtns = document.querySelectorAll('.projects-filter-btn');
    var projectCards = document.querySelectorAll('.project-card');
    if (!filterBtns.length || !projectCards.length) return;

    filterBtns.forEach(function (btn) {
        btn.addEventListener('click', function () {
            var filter = btn.getAttribute('data-filter');
            filterBtns.forEach(function (b) { b.classList.remove('active'); });
            btn.classList.add('active');

            projectCards.forEach(function (card) {
                var category = card.getAttribute('data-category');
                if (filter === 'all' || category === filter) {
                    card.style.display = 'flex';
                } else {
                    card.style.display = 'none';
                }
            });
        });
    });
}


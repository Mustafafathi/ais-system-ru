/**
 * Lightweight dashboard data visualizations.
 * Pure UI layer: consumes values already returned to dashboard pages.
 */
(function () {
    'use strict';

    function esc(value) {
        return String(value == null ? '' : value).replace(/[&<>"']/g, function (ch) {
            return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[ch];
        });
    }

    function toNumber(value, fallback) {
        if (value === null || value === undefined || value === '—') return fallback == null ? 0 : fallback;
        var normalized = String(value).replace('%', '').replace('ч', '').replace(/\s+/g, '').replace(',', '.');
        var n = parseFloat(normalized);
        return isNaN(n) ? (fallback == null ? 0 : fallback) : n;
    }

    function clamp(value, min, max) {
        return Math.max(min, Math.min(max, value));
    }

    function tone(value, explicit) {
        if (explicit) return explicit;
        var n = toNumber(value, 0);
        if (window.AIS && n < window.AIS.critThresh) return 'err';
        if (window.AIS && n < window.AIS.riskThresh) return 'warn';
        return 'ok';
    }

    function resolveTarget(target) {
        return typeof target === 'string' ? document.getElementById(target) : target;
    }

    function maxFrom(items) {
        return Math.max(1, items.reduce(function (max, item) {
            return Math.max(max, toNumber(item.value, 0), toNumber(item.max, 0));
        }, 0));
    }

    function compactValue(value, unit) {
        var n = toNumber(value, 0);
        if (unit === '%') return Math.round(n) + '%';
        if (unit) return Math.round(n) + unit;
        return String(Math.round(n));
    }

    function metricHtml(metric) {
        return '<div class="chart-metric tone-' + esc(metric.tone || 'primary') + '">' +
            '<span class="chart-metric-value">' + esc(metric.value == null ? '—' : metric.value) + '</span>' +
            '<span class="chart-metric-label">' + esc(metric.label || '') + '</span>' +
            '</div>';
    }

    function ringHtml(card) {
        var ring = card.ring || {};
        var value = clamp(toNumber(ring.value, 0), 0, 100);
        var ringTone = tone(value, ring.tone || card.tone);
        var metrics = (card.metrics || []).map(metricHtml).join('');
        return '<div class="chart-ring-layout">' +
            '<div class="chart-ring tone-' + esc(ringTone) + '" style="--ring-fill:' + value + '%" role="img" aria-label="' + esc((ring.label || card.title || 'Показатель') + ': ' + Math.round(value) + '%') + '">' +
                '<div class="chart-ring-inner">' +
                    '<span class="chart-ring-value">' + Math.round(value) + '%</span>' +
                    '<span class="chart-ring-label">' + esc(ring.label || '') + '</span>' +
                '</div>' +
            '</div>' +
            (metrics ? '<div class="chart-metrics">' + metrics + '</div>' : '') +
        '</div>';
    }

    function barsHtml(card) {
        var items = (card.items || []).filter(Boolean);
        if (!items.length) return '<div class="chart-empty">Нет данных для графика</div>';
        var max = toNumber(card.max, 0) || maxFrom(items);
        return '<div class="chart-bars">' + items.map(function (item) {
            var value = toNumber(item.value, 0);
            var itemMax = toNumber(item.max, max) || max;
            var width = clamp((value / itemMax) * 100, 0, 100);
            var itemTone = tone(value, item.tone || card.tone || 'primary');
            return '<div class="chart-bar-row tone-' + esc(itemTone) + '">' +
                '<div class="chart-bar-top">' +
                    '<span class="chart-bar-label">' + esc(item.label || '') + '</span>' +
                    '<span class="chart-bar-value">' + esc(compactValue(value, item.unit || card.unit || '')) + '</span>' +
                '</div>' +
                '<div class="chart-bar-track" role="img" aria-label="' + esc((item.label || '') + ': ' + compactValue(value, item.unit || card.unit || '')) + '">' +
                    '<div class="chart-bar-fill" style="width:' + width + '%"></div>' +
                '</div>' +
            '</div>';
        }).join('') + '</div>';
    }

    function stackHtml(card) {
        var segments = (card.segments || []).filter(function (segment) {
            return toNumber(segment.value, 0) > 0;
        });
        if (!segments.length) return '<div class="chart-empty">Нет данных для распределения</div>';
        var total = segments.reduce(function (sum, segment) { return sum + toNumber(segment.value, 0); }, 0) || 1;
        var stack = '<div class="chart-stack" role="img" aria-label="' + esc(card.title || 'Распределение') + '">';
        segments.forEach(function (segment) {
            var value = toNumber(segment.value, 0);
            var width = clamp((value / total) * 100, 4, 100);
            stack += '<span class="chart-stack-segment tone-' + esc(segment.tone || 'primary') + '" style="width:' + width + '%" title="' + esc(segment.label + ': ' + value) + '"></span>';
        });
        stack += '</div><div class="chart-legend">';
        segments.forEach(function (segment) {
            stack += '<span class="chart-legend-item tone-' + esc(segment.tone || 'primary') + '">' +
                '<span class="chart-legend-dot"></span>' +
                '<span>' + esc(segment.label || '') + '</span>' +
                '<strong>' + esc(compactValue(segment.value, segment.unit || card.unit || '')) + '</strong>' +
            '</span>';
        });
        return stack + '</div>';
    }

    function cardBody(card) {
        if (card.type === 'ring') return ringHtml(card);
        if (card.type === 'stack') return stackHtml(card);
        return barsHtml(card);
    }

    function render(target, cards) {
        var el = resolveTarget(target);
        if (!el) return;
        var validCards = (cards || []).filter(Boolean);
        if (!validCards.length) {
            el.innerHTML = '';
            return;
        }
        el.innerHTML = validCards.map(function (card) {
            return '<section class="analytics-card" aria-label="' + esc(card.title || 'График') + '">' +
                '<div class="analytics-card-hdr">' +
                    '<div><div class="analytics-title">' + esc(card.title || '') + '</div>' +
                    (card.subtitle ? '<div class="analytics-sub">' + esc(card.subtitle) + '</div>' : '') + '</div>' +
                    (card.badge ? '<span class="analytics-badge">' + esc(card.badge) + '</span>' : '') +
                '</div>' +
                '<div class="analytics-card-body">' + cardBody(card) + '</div>' +
            '</section>';
        }).join('');
    }

    window.AISCharts = {
        render: render,
        toNumber: toNumber,
        tone: tone
    };
}());


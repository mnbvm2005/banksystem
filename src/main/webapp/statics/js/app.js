(function () {
    "use strict";

    var NUMERAL_FONT = "\"Cormorant Garamond\", Georgia, \"Times New Roman\", serif";

    function applySerifNumerals() {
        var root = document.body;
        if (!root) {
            return;
        }
        var excluded = "script, style, noscript, textarea, input, select, option, canvas, svg, .digit-serif";
        var walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, {
            acceptNode: function (node) {
                if (!node.nodeValue || !/[0-9０-９]/.test(node.nodeValue)) {
                    return NodeFilter.FILTER_REJECT;
                }
                if (node.parentElement && node.parentElement.closest(excluded)) {
                    return NodeFilter.FILTER_REJECT;
                }
                return NodeFilter.FILTER_ACCEPT;
            }
        });
        var nodes = [];
        while (walker.nextNode()) {
            nodes.push(walker.currentNode);
        }
        nodes.forEach(function (node) {
            var fragment = document.createDocumentFragment();
            var parts = node.nodeValue.split(/([¥￥$€£]?\s?[-+]?[0-9０-９][0-9０-９,，.．/:：%％-]*)/g);
            parts.forEach(function (part) {
                if (!part) {
                    return;
                }
                if (/[0-9０-９]/.test(part)) {
                    var span = document.createElement("span");
                    span.className = "digit-serif";
                    span.textContent = part;
                    fragment.appendChild(span);
                } else {
                    fragment.appendChild(document.createTextNode(part));
                }
            });
            node.parentNode.replaceChild(fragment, node);
        });
    }

    function setCurrentDate() {
        var target = document.getElementById("currentDate");
        if (!target) {
            return;
        }
        var now = new Date();
        target.textContent = now.toLocaleDateString("en-US", {
            year: "numeric",
            month: "short",
            day: "2-digit",
            weekday: "short"
        });
    }

    function autoDismissAlerts() {
        var alerts = document.querySelectorAll(".alert");
        alerts.forEach(function (alert) {
            window.setTimeout(function () {
                alert.classList.add("alert-fade");
            }, 3600);
        });
    }

    function showToast(message) {
        if (!window.bootstrap || !message) {
            return;
        }
        var container = document.querySelector(".toast-container");
        if (!container) {
            container = document.createElement("div");
            container.className = "toast-container position-fixed top-0 end-0 p-3";
            container.style.zIndex = "1080";
            document.body.appendChild(container);
        }
        var toastElement = document.createElement("div");
        toastElement.className = "toast toast-modern";
        toastElement.setAttribute("role", "status");
        toastElement.setAttribute("aria-live", "polite");
        toastElement.innerHTML = "<div class=\"toast-body\"><i class=\"bi bi-check-circle text-success me-2\"></i>" + message + "</div>";
        container.appendChild(toastElement);
        var toast = new bootstrap.Toast(toastElement, { delay: 3200 });
        toast.show();
        toastElement.addEventListener("hidden.bs.toast", function () {
            toastElement.remove();
        });
    }

    function bindTableSearch() {
        var inputs = document.querySelectorAll(".js-table-search");
        inputs.forEach(function (input) {
            if (input.classList.contains("js-transaction-search")) {
                return;
            }
            input.addEventListener("input", function () {
                var target = document.querySelector(input.getAttribute("data-target"));
                if (!target) {
                    return;
                }
                var keyword = input.value.trim().toLowerCase();
                target.querySelectorAll("tbody tr").forEach(function (row) {
                    row.style.display = row.textContent.toLowerCase().indexOf(keyword) === -1 ? "none" : "";
                });
            });
        });
    }

    function bindTransactionFilters() {
        var table = document.getElementById("transactionTable");
        var search = document.querySelector(".js-transaction-search");
        var filters = document.querySelectorAll(".js-transaction-filter");
        var clear = document.querySelector(".transaction-clear");
        if (!table) {
            return;
        }

        function normalized(value) {
            return (value || "").trim().toLowerCase();
        }

        function selected(filterName) {
            var control = document.querySelector(".js-transaction-filter[data-filter=\"" + filterName + "\"]");
            if (!control) {
                return "";
            }
            var value = normalized(control.value);
            return value.indexOf("all ") === 0 ? "" : value;
        }

        function applyFilters() {
            var keyword = search ? normalized(search.value) : "";
            var type = selected("type");
            var status = selected("status");
            var account = selected("account");
            table.querySelectorAll("tbody tr").forEach(function (row) {
                var rowText = normalized(row.textContent);
                var rowType = normalized(row.getAttribute("data-type"));
                var rowStatus = normalized(row.getAttribute("data-status"));
                var rowAccount = normalized(row.getAttribute("data-account"));
                var visible = (!keyword || rowText.indexOf(keyword) >= 0)
                    && (!type || rowType === type)
                    && (!status || rowStatus === status)
                    && (!account || rowAccount === account);
                row.style.display = visible ? "" : "none";
            });
        }

        if (search) {
            search.addEventListener("input", applyFilters);
        }
        filters.forEach(function (filter) {
            filter.addEventListener("change", applyFilters);
        });
        if (clear) {
            clear.addEventListener("click", function () {
                if (search) {
                    search.value = "";
                }
                filters.forEach(function (filter) {
                    filter.selectedIndex = 0;
                });
                applyFilters();
            });
        }
    }

    function bindGlobalSearch() {
        var input = document.querySelector(".js-global-search");
        var results = document.querySelector(".global-search-results");
        if (!input || !results) {
            return;
        }

        var firstPath = window.location.pathname.split("/")[1] || "";
        var base = firstPath ? "/" + firstPath : "";
        var items = [
            { title: "Dashboard", desc: "Executive overview and asset charts", href: "/index", terms: "home overview assets chart dashboard" },
            { title: "Accounts", desc: "Balances and linked bank accounts", href: "/account", terms: "account balance saving current bank" },
            { title: "Transactions", desc: "Ledger, inflow, outflow, and black box records", href: "/transactions", terms: "transaction ledger inflow outflow record search black box" },
            { title: "Deposit", desc: "Add funds to an account", href: "/deposit", terms: "deposit income add money" },
            { title: "Withdraw", desc: "Withdraw money from an account", href: "/withdraw", terms: "withdraw cash outflow" },
            { title: "Transfer", desc: "Move money between accounts", href: "/transfer", terms: "transfer send wire money" },
            { title: "Payment", desc: "Pay bills and service providers", href: "/payment", terms: "payment bill pay expense" },
            { title: "Bills", desc: "Income and expense bill records", href: "/bill", terms: "bill income expense calendar" },
            { title: "Finance", desc: "Budgets and financial insights", href: "/finance", terms: "finance budget insights" },
            { title: "Holdings", desc: "Investment and holding records", href: "/holding", terms: "holding investment portfolio" },
            { title: "Notifications", desc: "Security and system messages", href: "/notifications", terms: "notification alert security" },
            { title: "Logs", desc: "Operation audit logs", href: "/logs", terms: "logs audit operation" },
            { title: "Approval", desc: "Pending review workflow", href: "/approval", terms: "approval pending review" }
        ];

        function closeResults() {
            results.classList.remove("is-open");
            results.innerHTML = "";
        }

        function render(matches) {
            if (!matches.length) {
                results.innerHTML = "<div class=\"global-search-empty\">No matching page found</div>";
                results.classList.add("is-open");
                return;
            }
            results.innerHTML = matches.slice(0, 6).map(function (item) {
                return "<a href=\"" + base + item.href + "\"><strong>" + item.title + "</strong><span>" + item.desc + "</span></a>";
            }).join("");
            results.classList.add("is-open");
        }

        input.addEventListener("input", function () {
            var keyword = input.value.trim().toLowerCase();
            if (!keyword) {
                closeResults();
                return;
            }
            render(items.filter(function (item) {
                return (item.title + " " + item.desc + " " + item.terms).toLowerCase().indexOf(keyword) >= 0;
            }));
        });

        input.addEventListener("keydown", function (event) {
            if (event.key !== "Enter") {
                return;
            }
            var first = results.querySelector("a");
            if (first) {
                event.preventDefault();
                window.location.href = first.href;
            }
        });

        document.addEventListener("click", function (event) {
            if (!event.target.closest(".topbar-search")) {
                closeResults();
            }
        });
    }

    function bindPasswordToggle() {
        var buttons = document.querySelectorAll(".password-toggle");
        buttons.forEach(function (button) {
            button.addEventListener("click", function () {
                var field = button.parentElement ? button.parentElement.querySelector("input") : null;
                var icon = button.querySelector("img");
                if (!field || !icon) {
                    return;
                }
                var showing = field.type === "text";
                field.type = showing ? "password" : "text";
                icon.src = showing ? button.getAttribute("data-eye") : button.getAttribute("data-eye-off");
            });
        });
    }

    function bindTooltips() {
        if (!window.bootstrap) {
            return;
        }

        document.querySelectorAll(".bi-info-circle").forEach(function (icon) {
            if (icon.getAttribute("title") || icon.getAttribute("data-bs-title")) {
                return;
            }
            var heading = icon.closest("h1, h2, h3");
            var headingText = heading ? heading.textContent.replace(/\s+/g, " ").trim() : "this section";
            icon.setAttribute("tabindex", "0");
            icon.setAttribute("data-bs-toggle", "tooltip");
            icon.setAttribute("data-bs-title", "More information about " + headingText.replace(/More information about/i, "").trim());
        });

        document.querySelectorAll("button, a").forEach(function (control) {
            if (control.getAttribute("title") || control.getAttribute("data-bs-title")) {
                return;
            }
            var label = control.getAttribute("aria-label");
            if (!label) {
                return;
            }
            control.setAttribute("data-bs-toggle", "tooltip");
            control.setAttribute("data-bs-title", label);
        });

        document.querySelectorAll("[data-bs-toggle=\"tooltip\"], [title]").forEach(function (element) {
            if (element.getAttribute("data-tooltip-bound") === "true") {
                return;
            }
            element.setAttribute("data-tooltip-bound", "true");
            new bootstrap.Tooltip(element, {
                container: "body",
                trigger: "hover focus"
            });
        });
    }

    function bindSidebarToggle() {
        var toggle = document.querySelector(".sidebar-toggle");
        if (!toggle) {
            return;
        }
        toggle.addEventListener("click", function () {
            document.body.classList.toggle("sidebar-open");
        });

        document.querySelectorAll(".sidebar-menu a").forEach(function (link) {
            link.addEventListener("click", function () {
                document.body.classList.remove("sidebar-open");
            });
        });
    }

    function bindTransferConfirm() {
        var form = document.querySelector("form[data-confirm-transfer='true']");
        var modalElement = document.getElementById("transferConfirmModal");
        var confirmButton = document.getElementById("transferConfirmSubmit");
        var confirmText = document.getElementById("transferConfirmText");
        if (!form || !modalElement || !confirmButton || !window.bootstrap) {
            return;
        }

        var modal = new bootstrap.Modal(modalElement);
        var confirmed = false;

        form.addEventListener("submit", function (event) {
            if (confirmed) {
                return;
            }

            var toAccount = document.getElementById("toAccountNo");
            var amount = document.getElementById("amount");
            if (!toAccount.value.trim()) {
                return;
            }
            if (!amount.value || Number(amount.value) <= 0) {
                return;
            }

            event.preventDefault();
            confirmText.textContent = "Confirm transfer of ￥" + amount.value + " to account " + toAccount.value.trim() + "?";
            modal.show();
        });

        confirmButton.addEventListener("click", function () {
            confirmed = true;
            modal.hide();
            form.submit();
        });
    }

    function bindRecentPager() {
        var table = document.querySelector(".js-recent-pager");
        if (!table) {
            return;
        }
        var rows = Array.prototype.slice.call(table.querySelectorAll(".js-recent-row"));
        var pageSize = Number(table.getAttribute("data-page-size")) || 3;
        var pageLabel = document.querySelector(".js-recent-page");
        var prev = document.querySelector(".js-recent-prev");
        var next = document.querySelector(".js-recent-next");
        var page = 0;
        var totalPages = Math.max(Math.ceil(rows.length / pageSize), 1);

        function render() {
            rows.forEach(function (row, index) {
                var visible = index >= page * pageSize && index < (page + 1) * pageSize;
                row.style.display = visible ? "" : "none";
            });
            if (pageLabel) {
                pageLabel.textContent = (page + 1) + " / " + totalPages;
            }
            if (prev) {
                prev.disabled = page === 0;
            }
            if (next) {
                next.disabled = page >= totalPages - 1;
            }
        }

        if (prev) {
            prev.addEventListener("click", function () {
                if (page > 0) {
                    page -= 1;
                    render();
                }
            });
        }
        if (next) {
            next.addEventListener("click", function () {
                if (page < totalPages - 1) {
                    page += 1;
                    render();
                }
            });
        }
        render();
    }

    function createCharts() {
        if (!window.Chart) {
            return;
        }

        Chart.defaults.font.family = "Inter, \"PingFang SC\", system-ui, sans-serif";
        function formatYen(value) {
            return "¥" + Number(value).toLocaleString("en-US", {
                maximumFractionDigits: 0
            });
        }

        var axisTickFont = {
            family: NUMERAL_FONT,
            size: 12,
            weight: "600"
        };

        var cashflow = document.getElementById("cashflowChart");
        if (cashflow) {
            var ctx = cashflow.getContext("2d");
            var fillGradient = ctx.createLinearGradient(0, 0, 0, cashflow.clientHeight || 220);
            fillGradient.addColorStop(0, "rgba(8, 20, 33, 0.16)");
            fillGradient.addColorStop(1, "rgba(8, 20, 33, 0.015)");
            var assetRanges = {
                month: {
                    labels: ["Apr 29", "May 3", "May 7", "May 11", "May 15", "May 19", "May 23", "May 29"],
                    data: [720000, 800000, 870000, 960000, 1040000, 1140000, 1210000, 1274580],
                    min: 700000,
                    max: 1300000
                },
                quarter: {
                    labels: ["Mar 1", "Mar 15", "Apr 1", "Apr 15", "May 1", "May 15", "Jun 1", "Jun 13"],
                    data: [820000, 885000, 960000, 1035000, 1100000, 1180000, 1235000, 1274580],
                    min: 780000,
                    max: 1320000
                },
                year: {
                    labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
                    data: [610000, 695000, 840000, 990000, 1140000, 1274580, 1274580, 1274580, 1274580, 1274580, 1274580, 1274580],
                    min: 560000,
                    max: 1320000
                }
            };
            var activeRange = assetRanges.month;
            var cashflowChart = new Chart(cashflow, {
                type: "line",
                data: {
                    labels: activeRange.labels,
                    datasets: [{
                        label: "Total Assets",
                        data: activeRange.data,
                        borderColor: "#081421",
                        backgroundColor: fillGradient,
                        pointBackgroundColor: "#081421",
                        pointBorderColor: "#D6AF5F",
                        pointHoverBackgroundColor: "#D6AF5F",
                        pointHoverBorderColor: "#081421",
                        pointRadius: 3.5,
                        pointHoverRadius: 5,
                        borderWidth: 3,
                        tension: 0.32,
                        fill: true
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        x: {
                            grid: {
                                display: false
                            },
                            ticks: {
                                font: axisTickFont
                            }
                        },
                        y: {
                            min: activeRange.min,
                            max: activeRange.max,
                            grid: {
                                color: "rgba(8, 20, 33, 0.065)"
                            },
                            ticks: {
                                font: axisTickFont,
                                callback: function (value) {
                                    return formatYen(value);
                                }
                            }
                        }
                    }
                }
            });
            var rangeControl = document.querySelector(".js-chart-range[data-target=\"cashflowChart\"]");
            if (rangeControl) {
                rangeControl.addEventListener("change", function () {
                    var nextRange = assetRanges[rangeControl.value] || assetRanges.month;
                    cashflowChart.data.labels = nextRange.labels;
                    cashflowChart.data.datasets[0].data = nextRange.data;
                    cashflowChart.options.scales.y.min = nextRange.min;
                    cashflowChart.options.scales.y.max = nextRange.max;
                    cashflowChart.update();
                });
            }
        }

        var asset = document.getElementById("assetChart");
        if (asset) {
            var total = Number(asset.getAttribute("data-total")) || 1;
            var accountCount = Number(asset.getAttribute("data-accounts")) || 1;
            var mainAsset = Math.max(total * 0.72, 1);
            var otherAsset = Math.max(total - mainAsset, accountCount > 1 ? 1 : 0);
            new Chart(asset, {
                type: "bar",
                data: {
                    labels: ["Primary Account", "Other Accounts"],
                    datasets: [{
                        label: "Assets",
                        data: [mainAsset, otherAsset],
                        backgroundColor: ["#081421", "#D6AF5F"],
                        borderRadius: {
                            topLeft: 18,
                            topRight: 18,
                            bottomLeft: 0,
                            bottomRight: 0
                        },
                        borderSkipped: false,
                        borderWidth: 0,
                        barPercentage: 0.48,
                        categoryPercentage: 0.72
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            callbacks: {
                                label: function (context) {
                                    return formatYen(context.raw);
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            grid: {
                                color: "rgba(8, 20, 33, 0.10)",
                                drawTicks: false
                            },
                            border: {
                                color: "rgba(8, 20, 33, 0.18)"
                            },
                            ticks: {
                                color: "#6B6B6B",
                                padding: 14,
                                font: {
                                    family: NUMERAL_FONT,
                                    size: 13,
                                    weight: "700"
                                }
                            }
                        },
                        y: {
                            beginAtZero: true,
                            grid: {
                                color: "rgba(8, 20, 33, 0.12)",
                                drawTicks: false
                            },
                            border: {
                                color: "rgba(8, 20, 33, 0.18)"
                            },
                            ticks: {
                                color: "#6B6B6B",
                                padding: 10,
                                font: {
                                    family: NUMERAL_FONT,
                                    size: 13,
                                    weight: "700"
                                },
                                callback: function (value) {
                                    return formatYen(value);
                                }
                            }
                        }
                    }
                }
            });
        }

        var transactionType = document.getElementById("transactionTypeChart");
        if (transactionType) {
            var inflowData = Number(transactionType.getAttribute("data-inflow"));
            var outflowData = Number(transactionType.getAttribute("data-outflow"));
            var internalData = Number(transactionType.getAttribute("data-internal"));
            var hasServerData = !isNaN(inflowData) || !isNaN(outflowData) || !isNaN(internalData);
            var typeLabels = ["Inflow", "Outflow", "Internal"];
            var typeValues = [
                isNaN(inflowData) ? 0 : inflowData,
                isNaN(outflowData) ? 0 : outflowData,
                isNaN(internalData) ? 0 : internalData
            ];
            if (!hasServerData) {
                var counts = {};
                document.querySelectorAll("#transactionTable tbody [data-filter-value]").forEach(function (cell) {
                    var key = cell.getAttribute("data-filter-value");
                    counts[key] = (counts[key] || 0) + 1;
                });
                typeLabels = Object.keys(counts);
                typeValues = typeLabels.map(function (label) { return counts[label]; });
            }
            if (typeValues.reduce(function (sum, item) { return sum + item; }, 0) === 0) {
                typeLabels = ["No Data"];
                typeValues = [1];
            }
            new Chart(transactionType, {
                type: "doughnut",
                data: {
                    labels: typeLabels,
                    datasets: [{
                        data: typeValues,
                        backgroundColor: ["#081421", "#B8872F", "#D9C9AE"],
                        borderColor: "#FFFFFF",
                        borderWidth: 4,
                        hoverOffset: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: "66%",
                    plugins: { legend: { display: false } }
                }
            });
        }

        var transactionDirection = document.getElementById("transactionDirectionChart");
        if (transactionDirection) {
            var inbound = 0;
            var outbound = 0;
            document.querySelectorAll("#transactionTable tbody tr").forEach(function (row) {
                if (row.querySelector(".amount-out")) {
                    outbound += 1;
                } else if (row.querySelector(".amount-in")) {
                    inbound += 1;
                }
            });
            new Chart(transactionDirection, {
                type: "bar",
                data: {
                    labels: ["Inbound", "Outbound"],
                    datasets: [{
                        data: [inbound, outbound],
                        backgroundColor: ["#16A34A", "#DC2626"],
                        borderRadius: 10,
                        maxBarThickness: 52
                    }]
                },
                options: {
                    plugins: { legend: { display: false } },
                    scales: {
                        x: { grid: { display: false }, ticks: { font: axisTickFont } },
                        y: { beginAtZero: true, ticks: { precision: 0, font: axisTickFont } }
                    }
                }
            });
        }

        var billFlow = document.getElementById("billFlowChart");
        if (billFlow) {
            new Chart(billFlow, {
                type: "bar",
                data: {
                    labels: ["Income", "Expense"],
                    datasets: [{
                        data: [
                            Number(billFlow.getAttribute("data-income")) || 0,
                            Number(billFlow.getAttribute("data-expense")) || 0
                        ],
                        backgroundColor: ["#07111F", "#D39A2F"],
                        hoverBackgroundColor: ["#07111F", "#C8942E"],
                        borderRadius: 12,
                        maxBarThickness: 72
                    }]
                },
                options: {
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        x: {
                            grid: { display: false },
                            border: { color: "rgba(198, 181, 152, 0.75)" },
                            ticks: { color: "#303845", font: axisTickFont }
                        },
                        y: {
                            beginAtZero: true,
                            grid: { color: "rgba(198, 181, 152, 0.46)", borderDash: [4, 4] },
                            border: { color: "rgba(198, 181, 152, 0.75)" },
                            ticks: {
                                color: "#303845",
                                font: axisTickFont,
                                callback: function (value) { return formatYen(value); }
                            }
                        }
                    }
                }
            });
        }

        var blackboxRisk = document.getElementById("blackboxRiskChart");
        if (blackboxRisk) {
            var score = Number(blackboxRisk.getAttribute("data-score")) || 0;
            new Chart(blackboxRisk, {
                type: "doughnut",
                data: {
                    labels: ["Risk Score", "Remaining"],
                    datasets: [{
                        data: [score, Math.max(100 - score, 0)],
                        backgroundColor: [score >= 70 ? "#DC2626" : score >= 40 ? "#D97706" : "#16A34A", "#EEF2F7"],
                        borderWidth: 0
                    }]
                },
                options: {
                    cutout: "74%",
                    plugins: { legend: { display: false } }
                }
            });
        }
    }

    document.addEventListener("DOMContentLoaded", function () {
        setCurrentDate();
        applySerifNumerals();
        autoDismissAlerts();
        bindTableSearch();
        bindTransactionFilters();
        bindGlobalSearch();
        bindPasswordToggle();
        bindTooltips();
        bindSidebarToggle();
        bindTransferConfirm();
        bindRecentPager();
        createCharts();
        if (window.location.search.indexOf("success=transfer") >= 0) {
            showToast("Transfer completed. Transaction records have been updated.");
        }
    });
}());

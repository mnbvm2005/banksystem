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
            new Chart(cashflow, {
                type: "line",
                data: {
                    labels: ["Apr 29", "May 3", "May 7", "May 11", "May 15", "May 19", "May 23", "May 29"],
                    datasets: [{
                        label: "Total Assets",
                        data: [720000, 800000, 870000, 960000, 1040000, 1140000, 1210000, 1274580],
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
                            min: 700000,
                            max: 1300000,
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
            var counts = {};
            document.querySelectorAll("#transactionTable tbody [data-filter-value]").forEach(function (cell) {
                var key = cell.getAttribute("data-filter-value").replace(" Out", "").replace(" In", "");
                counts[key] = (counts[key] || 0) + 1;
            });
            var typeLabels = Object.keys(counts);
            if (typeLabels.length === 0) {
                typeLabels = ["No Data"];
                counts["No Data"] = 1;
            }
            new Chart(transactionType, {
                type: "doughnut",
                data: {
                    labels: typeLabels,
                    datasets: [{
                        data: typeLabels.map(function (label) { return counts[label]; }),
                        backgroundColor: ["#081421", "#2F5BEA", "#D6AF5F", "#16A34A", "#DC2626"],
                        borderWidth: 0
                    }]
                },
                options: {
                    cutout: "68%",
                    plugins: { legend: { position: "bottom" } }
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
                        backgroundColor: ["#16A34A", "#DC2626"],
                        borderRadius: 12,
                        maxBarThickness: 72
                    }]
                },
                options: {
                    plugins: { legend: { display: false } },
                    scales: {
                        x: { grid: { display: false }, ticks: { font: axisTickFont } },
                        y: {
                            beginAtZero: true,
                            ticks: { font: axisTickFont, callback: function (value) { return formatYen(value); } }
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
        bindPasswordToggle();
        bindSidebarToggle();
        bindTransferConfirm();
        createCharts();
        if (window.location.search.indexOf("success=transfer") >= 0) {
            showToast("Transfer completed. Transaction records have been updated.");
        }
    });
}());

function plotProfile(x,fun,absCrit,fourSpace)
    plotArg = cell(6,1);
        plotArg{1} = x;
        plotArg{3} = x;
        plotArg{5} = x;
        
    if absCrit
        plotArg{2} = abs(real(fun));
        plotArg{4} = abs(imag(fun));
        plotArg{6} = abs(fun);
    else
        plotArg{2} = real(fun);
        plotArg{4} = imag(fun);
        plotArg{6} = abs(fun);
    end
    plot(plotArg{:},'LineWidth',2.5)
    if absCrit
        if fourSpace
            legend({'$|$real$(u^k)|$','$|$imag$(u^k)|$','$|u^k|$'},'Interpreter','latex')
        else
            legend({'$|$real$(u(x))|$','$|$imag$(u(x))|$','$|u(x)|$'},'Interpreter','latex')
        end
    else
        if fourSpace
            legend({'real$(u^k)$','imag$(u^k)$','$|u^k|$'},'Interpreter','latex')
        else
            legend({'real$(u(x))$','imag$(u(x))$','$|u(x)|$'},'Interpreter','latex')
        end
    end
end
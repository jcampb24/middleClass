%The function used above to calculate |support| and |distribution| is adapted from
% |gauher.c| in \cite{cup1992PressTeukolskyVetterlingFlannery}. In its original context of numerical 
%integration, the support and distribution of the discrete random variable correspond to the integration rule's
%\emph{abscissa} and \emph{weights}. The function
%takes a single input, |n|,  which should be an odd integer. Its outputs are
%vectors containing the |n|-point Gauss-Hermite abscissa (|x|) and weights (|w|) for
%integration with the kernel $e^{-x^2/2}/\sqrt{2\pi}$ from $-\infty$ to $\infty$.
%
%\begin{hiddencode}
function [x, w]=gaussHermiteQuadrature(n)
validateattributes(n,{'numeric'},{'odd','positive'},'gaussHermiteQuadrature.m');

x=zeros(n,1);
w=zeros(n,1);

    maximumIterations=200; %Maximum Newton's method iterations.   
    PIM4=1/pi^(1/4); %$\pi^{-1/4}$
    %Since the roots of the Gauss-Hermite polynomials are  
    %symmetric about zero, we only calculate half of them.
    m=(n+1)/2;    
    i=1;
    while(i<=m)
    %Each root is calculated by refining an initial guess with Newton's
    %method. We put the initial guess in |z|.        
        if(i==1)           
            z=sqrt((2*n+1)-1.85575*(2*n+1)^(-0.166667));
        elseif(i==2)
            z=z-1.14*(n^.426)/z;
        elseif(i==3)
            z=1.86*z-0.86*x(1);
        elseif(i==4)
            z=1.91*z-0.91*x(2);
        else
            z=2*z-x(i-2);
        end
        
        iteration=1;
        while(iteration<=maximumIterations)
            p1=PIM4;
            p2=0;
            
            j=1;
            while(j<=n)
                p3=p2;
                p2=p1;
                p1=z*sqrt(2/j)*p2-sqrt((j-1)/j)*p3;
                j=j+1;
            end
            
            pp=sqrt(2*n)*p2;
            z1=z;
            z=z1-p1/pp;
            if(abs(z-z1)<=1e-10) 
                break;
            end
            iteration=iteration+1;
        end
        
        if(iteration>maximumIterations)
            error('Too many iterations');
        end
        
        x(i)=z;
        x(n+1-i)=-z;
        w(i)=2/(pp*pp);
        w(n+1-i)=w(i);
        i=i+1;

    end
    %Adjust the weights and abscissa so that they implement the standard
    %normal density function.
    x=sqrt(2)*x;
    w=w/sqrt(pi);
end
%\end{hiddencode}

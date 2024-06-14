Extension { #name : #HiRuler }

{ #category : #'*GToolkit4Git' }
HiRuler >> gtViewFor: aView [
	<gtView>
	| size column |
	size := 10.
	column := 20.
	^ aView columnedList
		title: 'Graph';
		items: [ self nodes ];
		column: 'Nodes'
			stencil: [ :each | 
				BlElement new
					height: size * 2;
					width: 100;
					addChild: (BlElement new
							background: (Color lightGray);
							border: (BlBorder paint: (Color black) width: 2);
							geometry: BlCircleGeometry new;
							size: size @ size;
							relocate: (each rulerPoint x * column) @ 0) ];
		send: [ :each | each theValue ]
]

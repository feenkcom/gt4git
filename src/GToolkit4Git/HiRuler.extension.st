Extension { #name : #HiRuler }

{ #category : #'*GToolkit4Git' }
HiRuler >> gtElementForRow: i [
	| column e each size |
	each := self nodes at: i.
	size := 10.
	column := 20.
	e := BlElement new
			height: size * 2;
			width: 100;
			addChild: (BlElement new
					background: Color lightGray;
					border: (BlBorder paint: Color black width: 2);
					geometry: BlCircleGeometry new;
					size: size @ size;
					relocate: (each rulerPoint x * column) @ 0).
	(self linksAtRow: i)
		do: [ :link | 
			| startX startY endX endY |
			startX := link origin rulerPoint x * column.
			endX := link target rulerPoint x * column.
			startY := (link origin rulerPoint y - i + 1) * size.
			endY := (link target rulerPoint y - i + 1) * size.
			e
				addChild: (BlManhattanLineElement new
						border: (BlBorder paint: Color red width: 1);
						cornerRadius: 5;
						fromAnchor: (BlAbsolutePositionAnchor position: startX @ startY);
						toAnchor: (BlAbsolutePositionAnchor position: endX @ endY)) ].
	^ e
]

{ #category : #'*GToolkit4Git' }
HiRuler >> gtElementForValue: anObject [
	^ self gtElementForRow: (self nodeAtValue: anObject) rulerPoint y
]

{ #category : #'*GToolkit4Git' }
HiRuler >> gtViewFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Graph';
		items: [ 1 to: self numberOfRows ];
		column: 'Nodes' stencil: [ :i | self gtElementForRow: i ];
		send: [ :i | (self nodes at: i) theValue ]
]

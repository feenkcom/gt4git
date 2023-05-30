Class {
	#name : #GtGitDiscardAndLoad,
	#superclass : #GtGitRepairAction,
	#category : #'GToolkit4Git-Inspector Integration - Actions'
}

{ #category : #accessing }
GtGitDiscardAndLoad class >> iceTipClass [
	^ IceTipRepairDiscardAndLoad
]

{ #category : #accessing }
GtGitDiscardAndLoad >> repairStencil [
	| container |
	container := BrVerticalPane new.
	container matchParent.
	container padding: (BlInsets all: 10).
	repository branch checkout.
	Iceberg announcer announce: (IceRepositoryModified for: repository).
	dropdown
		ifNotNil: [ dropdown
				enqueueTask: (BlTaskAction new
						action: [ dropdown dispatchEvent: (BrDropdownHideWish new anchor: dropdown).
							dropdown phlow fireUpdateWish ]) ].
	^ container
]

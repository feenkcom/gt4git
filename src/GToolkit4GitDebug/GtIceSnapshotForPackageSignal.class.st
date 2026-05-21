Class {
	#name : #GtIceSnapshotForPackageSignal,
	#superclass : #GtIceSignal,
	#instVars : [
		'savedPackage',
		'savedVersion',
		'snapshot',
		'mcVersion',
		'versionExists'
	],
	#category : #'GToolkit4GitDebug-Signals'
}

{ #category : #'gt - extensions' }
GtIceSnapshotForPackageSignal >> gtOverviewFor: aView [
	<gtView>
	^ aView details
		title: 'Overview';
		priority: 0;
		row: 'Saved package' value: [ self savedPackage ];
		row: 'Saved version' value: [ self savedVersion ];
		row: 'MC version' value: [ self mcVersion ];
		row: 'Snapshot' value: [ self snapshot ];
		row: 'Version exists' value: [ self versionExists ]
]

{ #category : #accessing }
GtIceSnapshotForPackageSignal >> mcVersion [
	^ mcVersion
]

{ #category : #accessing }
GtIceSnapshotForPackageSignal >> mcVersion: anObject [
	mcVersion := anObject
]

{ #category : #printing }
GtIceSnapshotForPackageSignal >> printOneLineContentsOn: aStream [
	aStream print: savedPackage.
	aStream space.
	aStream print: savedVersion.
	aStream space.
	aStream print: mcVersion.
	aStream space.
	aStream print: snapshot
]

{ #category : #accessing }
GtIceSnapshotForPackageSignal >> savedPackage [
	^ savedPackage
]

{ #category : #accessing }
GtIceSnapshotForPackageSignal >> savedPackage: anObject [
	savedPackage := anObject
]

{ #category : #accessing }
GtIceSnapshotForPackageSignal >> savedVersion [
	^ savedVersion
]

{ #category : #accessing }
GtIceSnapshotForPackageSignal >> savedVersion: anObject [
	savedVersion := anObject
]

{ #category : #accessing }
GtIceSnapshotForPackageSignal >> snapshot [
	^ snapshot
]

{ #category : #accessing }
GtIceSnapshotForPackageSignal >> snapshot: anObject [
	snapshot := anObject
]

{ #category : #accessing }
GtIceSnapshotForPackageSignal >> versionDoesNotExist [
	versionExists := false
]

{ #category : #accessing }
GtIceSnapshotForPackageSignal >> versionExists [
	^ versionExists ifNil: [ true ]
]

/**
 * ATFutures, LIDA/ITS, University of Leeds
 * Entry component for ATT
 */
import React, { Component } from 'react';
import { Map, TileLayer } from 'react-leaflet';
import Control from 'react-leaflet-control';

import GeoJSONComponent from './components/GeoJSONComponent.jsx';

import './App.css';
import RailUse from './components/RailUse.jsx';

export default class Welcome extends Component {
    constructor(props) {
        super(props);
        this.state = {
            sfParam: null,
            map: null
        }
    }

    componentDidMount() {
        const map = this.refs.map.leafletElement
        this.setState({ map })
        // get regions
    }

    render() {
        return (
            <Map
                preferCanvas={true}
                zoom={13}
                ref='map'
                center={[53.8008, -1.5491]}
                onclick={(e) => {
                    this.setState({ touchReceived: true })
                }}
            >
                <Control className="leaflet-control-attribution leaflet-control"
                    position={this.props.position || "bottomright"}>
                    {this.state.label}
                </Control>
                <TileLayer
                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                    attribution="&copy; <a href=&quot;http://osm.org/copyright&quot;>OpenStreetMap</a> contributors"
                />
                {/* #ADD_COMPONENT */}
                <GeoJSONComponent style={{color:'#00ff00'}} fetchURL='http://localhost:8000/api/target' map={ this.state.map } />
                <GeoJSONComponent style={() => {}} fetchURL='http://localhost:8000/api/trips' map={ this.state.map } />
                <RailUse style={{color:'#000'}} fetchURL='http://localhost:8000/api/lines' map={ this.state.map } />

            </Map>
        );
    }
}

